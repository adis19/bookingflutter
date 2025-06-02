import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/hotel_model.dart';
import '../models/search_params_model.dart';

class HotelService extends ChangeNotifier {
  final Dio _dio = Dio();
  
  String? _accessToken;
  DateTime? _tokenExpiry;
  bool _isLoading = false;
  String? _errorMessage;
  List<HotelModel> _searchResults = [];
  List<String> _searchHistory = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<HotelModel> get searchResults => _searchResults;
  List<String> get searchHistory => _searchHistory;

  HotelService() {
    _init();
  }

  void _init() {
    _loadSearchHistory();
    _loadStoredToken();
    _setupDioInterceptors();
  }

  void _setupDioInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  // Load stored access token
  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(AppConstants.amadeusTokenKey);
      
      final expiryString = prefs.getString(AppConstants.tokenExpiryKey);
      if (expiryString != null) {
        _tokenExpiry = DateTime.parse(expiryString);
        
        // Check if token is expired
        if (_tokenExpiry!.isBefore(DateTime.now())) {
          _accessToken = null;
          _tokenExpiry = null;
          await _clearStoredToken();
        }
      }
    } catch (e) {
      debugPrint('Error loading stored token: $e');
    }
  }

  // Save access token
  Future<void> _saveToken(String token, int expiresIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = token;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60)); // 1 minute buffer
      
      await prefs.setString(AppConstants.amadeusTokenKey, token);
      await prefs.setString(AppConstants.tokenExpiryKey, _tokenExpiry!.toIso8601String());
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  // Clear stored token
  Future<void> _clearStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.amadeusTokenKey);
      await prefs.remove(AppConstants.tokenExpiryKey);
    } catch (e) {
      debugPrint('Error clearing token: $e');
    }
  }

  // Get Amadeus access token
  Future<bool> _getAccessToken() async {
    if (_accessToken != null && 
        _tokenExpiry != null && 
        _tokenExpiry!.isAfter(DateTime.now())) {
      return true;
    }

    try {
      final response = await _dio.post(
        '${AppConstants.amadeusBaseUrl}/v1/security/oauth2/token',
        data: {
          'grant_type': 'client_credentials',
          'client_id': AppConstants.amadeusApiKey,
          'client_secret': AppConstants.amadeusApiSecret,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveToken(data['access_token'], data['expires_in']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error getting access token: $e');
      _setError('Ошибка авторизации API');
      return false;
    }
  }

  // Search hotels by city
  Future<List<HotelModel>> searchHotels(SearchParamsModel searchParams) async {
    try {
      _setLoading(true);
      _setError(null);

      // Get access token first
      if (!await _getAccessToken()) {
        return [];
      }

      // Add to search history
      await _addToSearchHistory(searchParams.destination);

      // Search for city/location first
      final locationResponse = await _dio.get(
        '${AppConstants.amadeusBaseUrl}/v1/reference-data/locations',
        queryParameters: {
          'keyword': searchParams.destination,
          'subType': 'CITY',
        },
      );

      if (locationResponse.statusCode != 200 || 
          locationResponse.data['data'].isEmpty) {
        _setError('Город не найден');
        return [];
      }

      final cityCode = locationResponse.data['data'][0]['iataCode'];

      // Search hotels
      final hotelsResponse = await _dio.get(
        '${AppConstants.amadeusBaseUrl}/v2/shopping/hotel-offers',
        queryParameters: {
          'cityCode': cityCode,
          'checkInDate': searchParams.checkInDate.toIso8601String().split('T')[0],
          'checkOutDate': searchParams.checkOutDate.toIso8601String().split('T')[0],
          'adults': searchParams.adults,
          'roomQuantity': searchParams.rooms,
          'currency': 'USD',
          'bestRateOnly': true,
          'lang': 'RU',
        },
      );

      if (hotelsResponse.statusCode == 200) {
        final data = hotelsResponse.data['data'] as List;
        _searchResults = data.map((json) => HotelModel.fromAmadeusJson(json)).toList();
        notifyListeners();
        return _searchResults;
      } else {
        _setError('Ошибка поиска отелей');
        return [];
      }
    } catch (e) {
      debugPrint('Error searching hotels: $e');
      _setError('Ошибка при поиске отелей');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get hotel details
  Future<HotelModel?> getHotelDetails(String hotelId) async {
    try {
      _setLoading(true);
      _setError(null);

      if (!await _getAccessToken()) {
        return null;
      }

      final response = await _dio.get(
        '${AppConstants.amadeusBaseUrl}/v2/shopping/hotel-offers/by-hotel',
        queryParameters: {
          'hotelId': hotelId,
          'currency': 'USD',
          'lang': 'RU',
        },
      );

      if (response.statusCode == 200 && response.data['data'].isNotEmpty) {
        return HotelModel.fromAmadeusJson(response.data['data'][0]);
      } else {
        _setError('Отель не найден');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting hotel details: $e');
      _setError('Ошибка при получении данных отеля');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Load search history
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString(AppConstants.searchHistoryKey);
      if (historyString != null) {
        _searchHistory = historyString.split(',');
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  // Add to search history
  Future<void> _addToSearchHistory(String destination) async {
    try {
      if (!_searchHistory.contains(destination)) {
        _searchHistory.insert(0, destination);
        
        // Keep only last 10 searches
        if (_searchHistory.length > AppConstants.maxSearchHistoryItems) {
          _searchHistory = _searchHistory.take(AppConstants.maxSearchHistoryItems).toList();
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.searchHistoryKey, _searchHistory.join(','));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding to search history: $e');
    }
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    try {
      _searchHistory.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.searchHistoryKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing search history: $e');
    }
  }

  // Filter search results
  void filterResults({
    double? minPrice,
    double? maxPrice,
    int? minRating,
    List<String>? amenities,
  }) {
    // Apply filters to _searchResults
    // This is a simplified version - you can expand based on needs
    notifyListeners();
  }

  // Sort search results
  void sortResults(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        _searchResults.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        _searchResults.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        _searchResults.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        _searchResults.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    notifyListeners();
  }
}
