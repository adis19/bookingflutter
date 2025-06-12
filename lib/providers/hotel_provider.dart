import 'package:flutter/foundation.dart';
import '../models/hotel.dart';
import '../services/hotel_service.dart';

class HotelProvider with ChangeNotifier {
  final HotelService _hotelService = HotelService();
  
  List<Hotel> _searchResults = [];
  List<Hotel> _hotels = [];
  Hotel? _selectedHotel;
  bool _isLoading = false;
  String? _error;
  
  List<Hotel> get searchResults => _searchResults;
  List<Hotel> get hotels => _hotels;
  Hotel? get selectedHotel => _selectedHotel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Поиск отелей
  Future<void> searchHotels({
    String? query,
    String? location,
    int? radius,
    double? minRating,
    String? placeType,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      
      _searchResults = await _hotelService.searchHotels(
        query: query,
        location: location,
        radius: radius,
        minRating: minRating,
        placeType: placeType,
      );
      
      // Проверяем, получили ли мы какие-то результаты
      if (_searchResults.isEmpty) {
        final placeTypeText = placeType == 'restaurant' ? 'ресторанов' : 'отелей';
        _error = 'По вашему запросу не найдено $placeTypeText';
      }
    } catch (e) {
      final placeTypeText = placeType == 'restaurant' ? 'ресторанов' : 'отелей';
      _error = 'Ошибка при поиске $placeTypeText: $e';
      _searchResults = [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Получение детальной информации об отеле
  Future<void> getHotelDetails(String placeId) async {
    try {
      _setLoading(true);
      _error = null;
      
      final hotel = await _hotelService.getHotelDetails(placeId);
      
      // Проверяем, получили ли мы отель с ошибкой
      if (hotel.name == 'Ошибка загрузки') {
        _error = 'Не удалось загрузить информацию об отеле';
      }
      
      _selectedHotel = hotel;
    } catch (e) {
      _error = 'Ошибка при получении информации об отеле: $e';
      _selectedHotel = null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Получение отеля по ID
  Future<void> getHotelById(int id) async {
    try {
      _setLoading(true);
      _error = null;
      
      final hotel = await _hotelService.getHotelById(id);
      
      // Проверяем, получили ли мы отель с ошибкой
      if (hotel.name == 'Ошибка загрузки') {
        _error = 'Не удалось загрузить информацию об отеле';
      }
      
      _selectedHotel = hotel;
    } catch (e) {
      _error = 'Ошибка при получении информации об отеле: $e';
      _selectedHotel = null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Получение списка отелей
  Future<void> getHotels({
    int skip = 0,
    int limit = 20,
    String? search,
    bool refresh = false,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      
      final hotels = await _hotelService.getHotels(
        skip: skip,
        limit: limit,
        search: search,
      );
      
      if (refresh) {
        _hotels = hotels;
      } else {
        // Добавляем только уникальные отели
        final existingIds = _hotels.map((h) => h.id).toSet();
        final newHotels = hotels.where((h) => !existingIds.contains(h.id)).toList();
        _hotels.addAll(newHotels);
      }
      
      // Проверяем, получили ли мы какие-то результаты
      if (_hotels.isEmpty) {
        _error = 'Отели не найдены';
      }
    } catch (e) {
      _error = 'Ошибка при получении списка отелей: $e';
      if (refresh) {
        _hotels = [];
      }
    } finally {
      _setLoading(false);
    }
  }
  
  // Установка выбранного отеля
  void setSelectedHotel(Hotel hotel) {
    _selectedHotel = hotel;
    notifyListeners();
  }
  
  // Очистка результатов поиска
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
  
  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Установка состояния загрузки
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 