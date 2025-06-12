import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String defaultBaseUrl = 'http://192.168.0.105:8000/api';
  static const int timeoutSeconds = 15;
  
  late final String baseUrl;
  
  ApiService() {
    baseUrl = dotenv.env['API_BASE_URL'] ?? defaultBaseUrl;
    debugPrint('Инициализация API с базовым URL: $baseUrl');
  }
  
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    debugPrint('GET запрос к $endpoint${queryParameters != null ? " с параметрами: $queryParameters" : ""}');
    
    try {
      final response = await _makeRequest(
        () => http.get(
          _buildUri(endpoint, queryParameters: queryParameters),
          headers: _getHeaders(),
        ).timeout(const Duration(seconds: timeoutSeconds)),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Ошибка GET запроса к $endpoint: $e');
      
      // Для отладки возвращаем мок-данные в режиме разработки
      if (kDebugMode) {
        debugPrint('Возвращаем моковые данные для $endpoint');
        return _getMockData(endpoint);
      }
      
      rethrow;
    }
  }
  
  Future<List<dynamic>> getList(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    debugPrint('GET список к $endpoint${queryParameters != null ? " с параметрами: $queryParameters" : ""}');
    
    try {
      final response = await _makeRequest(
        () => http.get(
          _buildUri(endpoint, queryParameters: queryParameters),
          headers: _getHeaders(),
        ).timeout(const Duration(seconds: timeoutSeconds)),
      );
      
      final data = jsonDecode(response.body);
      
      if (data is List) {
        debugPrint('Получен список с ${data.length} элементами');
        return data;
      } else if (data is Map && data.containsKey('results')) {
        final results = data['results'] as List;
        debugPrint('Получен список с ${results.length} элементами из поля results');
        return results;
      } else {
        debugPrint('Неожиданный формат данных: ${data.runtimeType}. Преобразуем в пустой список.');
        return [];
      }
    } catch (e) {
      debugPrint('Ошибка GET списка к $endpoint: $e');
      
      // Для отладки возвращаем мок-данные в режиме разработки
      if (kDebugMode) {
        final mockData = _getMockData(endpoint);
        debugPrint('Возвращаем моковые данные для $endpoint: ${mockData.runtimeType}');
        
        if (mockData is List) {
          return mockData;
        } else if (mockData is Map && mockData.containsKey('results')) {
          return mockData['results'] as List;
        } else {
          return [];
        }
      }
      
      rethrow;
    }
  }
  
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) async {
    debugPrint('POST запрос к $endpoint с данными: $data${queryParameters != null ? " и параметрами: $queryParameters" : ""}');
    
    try {
      final response = await _makeRequest(
        () => http.post(
          _buildUri(endpoint, queryParameters: queryParameters),
          headers: _getHeaders(),
          body: data != null ? jsonEncode(data) : null,
        ).timeout(const Duration(seconds: timeoutSeconds)),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Ошибка POST запроса к $endpoint: $e');
      
      // Для отладки возвращаем мок-данные в режиме разработки
      if (kDebugMode) {
        debugPrint('Возвращаем моковые данные для POST запроса к $endpoint');
        return _getMockData('post$endpoint', data: data);
      }
      
      rethrow;
    }
  }
  
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) async {
    debugPrint('PUT запрос к $endpoint с данными: $data${queryParameters != null ? " и параметрами: $queryParameters" : ""}');
    
    try {
      final response = await _makeRequest(
        () => http.put(
          _buildUri(endpoint, queryParameters: queryParameters),
          headers: _getHeaders(),
          body: data != null ? jsonEncode(data) : null,
        ).timeout(const Duration(seconds: timeoutSeconds)),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Ошибка PUT запроса к $endpoint: $e');
      
      // Для отладки возвращаем мок-данные в режиме разработки
      if (kDebugMode) {
        debugPrint('Возвращаем моковые данные для PUT запроса к $endpoint');
        return _getMockData('put$endpoint', data: data);
      }
      
      rethrow;
    }
  }
  
  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    debugPrint('DELETE запрос к $endpoint${queryParameters != null ? " с параметрами: $queryParameters" : ""}');
    
    try {
      final response = await _makeRequest(
        () => http.delete(
          _buildUri(endpoint, queryParameters: queryParameters),
          headers: _getHeaders(),
        ).timeout(const Duration(seconds: timeoutSeconds)),
      );
      
      if (response.body.isEmpty) {
        return null;
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Ошибка DELETE запроса к $endpoint: $e');
      
      // Для отладки возвращаем null в режиме разработки
      if (kDebugMode) {
        debugPrint('Возвращаем null для DELETE запроса к $endpoint');
        return null;
      }
      
      rethrow;
    }
  }
  
  Uri _buildUri(String endpoint, {Map<String, dynamic>? queryParameters}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      
      final finalUrl = '$baseUrl$endpoint${uri.query.isEmpty ? '?' : '&'}$queryString';
      debugPrint('Построен URI с параметрами: $finalUrl');
      return Uri.parse(finalUrl);
    }
    
    debugPrint('Построен URI: $uri');
    return uri;
  }
  
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final token = AuthService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  Future<http.Response> _makeRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      
      debugPrint('Статус ответа: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? 'Ошибка запроса: ${response.statusCode}';
        } catch (e) {
          errorMessage = 'Ошибка запроса: ${response.statusCode}';
        }
        
        debugPrint('Ошибка API: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Ошибка запроса: $e');
      rethrow;
    }
  }
  
  // Моковые данные для отладки
  dynamic _getMockData(String endpoint, {Map<String, dynamic>? data}) {
    debugPrint('Генерируем моковые данные для $endpoint');
    
    // Избранное
    if (endpoint == '/favorites') {
      return [
        {
          'id': 1,
          'user_id': 1,
          'hotel_id': 1,
          'created_at': DateTime.now().toIso8601String(),
          'hotel': {
            'id': 1,
            'place_id': 'mock_place_id_1',
            'name': 'Отель Хаятт',
            'address': 'ул. Примерная, 123',
            'latitude': 42.87,
            'longitude': 74.59,
            'rating': 4.7,
            'user_ratings_total': 129,
            'created_at': DateTime.now().toIso8601String(),
            'place_type': 'hotel',
          },
        },
        {
          'id': 2,
          'user_id': 1,
          'hotel_id': 2,
          'created_at': DateTime.now().toIso8601String(),
          'hotel': {
            'id': 2,
            'place_id': 'mock_place_id_2',
            'name': 'Бишкек Плаза',
            'address': 'ул. Центральная, 456',
            'latitude': 42.86,
            'longitude': 74.58,
            'rating': 4.3,
            'user_ratings_total': 98,
            'created_at': DateTime.now().toIso8601String(),
            'place_type': 'hotel',
          },
        },
      ];
    }
    
    // Бронирования
    if (endpoint == '/bookings/my') {
      return [
        {
          'id': 1,
          'user_id': 1,
          'hotel_id': '1',
          'check_in_date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
          'check_out_date': DateTime.now().add(const Duration(days: 8)).toIso8601String(),
          'guests': 2,
          'status': 'confirmed',
          'notes': 'Прошу номер с видом на горы',
          'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'hotel': {
            'id': 1,
            'place_id': 'mock_place_id_1',
            'name': 'Отель Хаятт',
            'address': 'ул. Примерная, 123',
            'latitude': 42.87,
            'longitude': 74.59,
            'rating': 4.7,
            'user_ratings_total': 129,
            'created_at': DateTime.now().toIso8601String(),
            'place_type': 'hotel',
          },
          'total_price': 15000,
        },
        {
          'id': 2,
          'user_id': 1,
          'hotel_id': '2',
          'check_in_date': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
          'check_out_date': DateTime.now().add(const Duration(days: 20)).toIso8601String(),
          'guests': 3,
          'status': 'pending',
          'notes': null,
          'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'hotel': {
            'id': 2,
            'place_id': 'mock_place_id_2',
            'name': 'Бишкек Плаза',
            'address': 'ул. Центральная, 456',
            'latitude': 42.86,
            'longitude': 74.58,
            'rating': 4.3,
            'user_ratings_total': 98,
            'created_at': DateTime.now().toIso8601String(),
            'place_type': 'hotel',
          },
          'total_price': 25000,
        },
      ];
    }
    
    // Создание бронирования
    if (endpoint == 'post/bookings') {
      return {
        'id': 3,
        'user_id': 1,
        'hotel_id': data?['hotel_id'] ?? 'unknown',
        'check_in_date': data?['check_in_date'] ?? DateTime.now().toIso8601String(),
        'check_out_date': data?['check_out_date'] ?? DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'guests': data?['guests'] ?? 2,
        'status': 'pending',
        'notes': data?['notes'],
        'created_at': DateTime.now().toIso8601String(),
        'hotel': data?['hotelData'] ?? {
          'id': 999,
          'place_id': data?['hotel_id'] ?? 'unknown',
          'name': 'Мок-отель',
          'address': 'Адрес мок-отеля',
          'latitude': 42.8,
          'longitude': 74.5,
          'rating': 4.0,
          'user_ratings_total': 50,
          'created_at': DateTime.now().toIso8601String(),
          'place_type': 'hotel',
        },
        'total_price': 10000,
      };
    }
    
    // Проверка авторизации
    if (endpoint == '/auth/me') {
      return {
        'id': 1,
        'name': 'Тестовый пользователь',
        'email': 'test@example.com',
      };
    }
    
    // Если нет специфичных моковых данных, возвращаем общий шаблон
    return {
      'message': 'Моковые данные для $endpoint',
      'timestamp': DateTime.now().toIso8601String(),
      'endpoint': endpoint,
      'data': data,
    };
  }
}