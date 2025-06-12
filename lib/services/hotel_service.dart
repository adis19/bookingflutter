import 'api_service.dart';
import '../models/hotel.dart';
import '../models/mock_data.dart';
import 'package:flutter/foundation.dart';

class HotelService {
  final ApiService _apiService = ApiService();

  // Поиск отелей
  Future<List<Hotel>> searchHotels({
    String? query,
    String? location,
    int? radius,
    double? minRating,
    String? placeType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      
      if (radius != null) {
        queryParams['radius'] = radius;
      }
      
      if (minRating != null) {
        queryParams['min_rating'] = minRating;
      }
      
      // Добавляем параметр типа заведения
      if (placeType != null && placeType.isNotEmpty) {
        queryParams['type'] = placeType;
      }
      
      // Формируем путь в зависимости от типа заведения
      String searchPath = '/hotels/search';
      if (placeType == 'restaurant') {
        searchPath = '/restaurants/search';
        debugPrint('Выполняем поиск ресторанов с параметрами: $queryParams');
      } else {
        debugPrint('Выполняем поиск отелей с параметрами: $queryParams');
      }
      
      try {
        final response = await _apiService.getList(searchPath, queryParameters: queryParams);
        debugPrint('Получено ${response.length} результатов поиска');
        
        List<Hotel> hotels = [];
        for (var item in response) {
          try {
            // Устанавливаем тип заведения
            if (placeType != null && placeType.isNotEmpty) {
              item['place_type'] = placeType;
            }
            
            // Проверяем и исправляем обязательные поля
            _validateAndFixHotelData(item);
            hotels.add(Hotel.fromJson(item));
          } catch (e) {
            debugPrint('Ошибка при создании объекта Hotel: $e');
            debugPrint('Проблемный JSON: $item');
            // Продолжаем обработку других отелей
          }
        }
        
        debugPrint('Успешно обработано ${hotels.length} заведений');
        
        // Если не получили результаты от API, возвращаем моковые данные
        if (hotels.isEmpty) {
          return _getMockData(placeType);
        }
        
        return hotels;
      } catch (e) {
        debugPrint('Ошибка запроса к API: $e. Возвращаем моковые данные.');
        // Возвращаем моковые данные в случае ошибки
        return _getMockData(placeType);
      }
    } catch (e) {
      debugPrint('Error searching places: $e. Возвращаем моковые данные.');
      // В случае ошибки возвращаем моковые данные
      return _getMockData(placeType);
    }
  }
  
  // Получение моковых данных в зависимости от типа места
  List<Hotel> _getMockData(String? placeType) {
    if (placeType == 'restaurant') {
      return MockData.getMockRestaurants();
    } else {
      return MockData.getMockHotels();
    }
  }

  // Получение детальной информации об отеле по place_id
  Future<Hotel> getHotelDetails(String placeId) async {
    try {
      debugPrint('Запрашиваем детали отеля с place_id: $placeId');
      final response = await _apiService.get('/hotels/details/$placeId');
      
      // Проверяем и исправляем обязательные поля
      _validateAndFixHotelData(response);
      
      debugPrint('Получены детали отеля: ${response['name']}');
      return Hotel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting hotel details: $e');
      
      // Создаем заглушку отеля с минимальной информацией
      return Hotel(
        id: 0,
        placeId: placeId,
        name: 'Ошибка загрузки',
        address: 'Не удалось загрузить информацию об отеле',
        latitude: 0,
        longitude: 0,
        createdAt: DateTime.now(),
      );
    }
  }

  // Получение отеля по ID
  Future<Hotel> getHotelById(int id) async {
    try {
      debugPrint('Запрашиваем отель с ID: $id');
      final response = await _apiService.get('/hotels/$id');
      
      // Проверяем и исправляем обязательные поля
      _validateAndFixHotelData(response);
      
      debugPrint('Получен отель: ${response['name']}');
      return Hotel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting hotel by ID: $e');
      
      // Создаем заглушку отеля с минимальной информацией
      return Hotel(
        id: id,
        placeId: 'unknown',
        name: 'Ошибка загрузки',
        address: 'Не удалось загрузить информацию об отеле',
        latitude: 0,
        longitude: 0,
        createdAt: DateTime.now(),
      );
    }
  }

  // Получение списка отелей из базы данных
  Future<List<Hotel>> getHotels({
    int skip = 0,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      debugPrint('Запрашиваем список отелей с параметрами: $queryParams');
      final response = await _apiService.getList('/hotels', queryParameters: queryParams);
      debugPrint('Получено ${response.length} отелей из базы данных');
      
      List<Hotel> hotels = [];
      for (var item in response) {
        try {
          // Проверяем и исправляем обязательные поля
          _validateAndFixHotelData(item);
          hotels.add(Hotel.fromJson(item));
        } catch (e) {
          debugPrint('Ошибка при создании объекта Hotel: $e');
          debugPrint('Проблемный JSON: $item');
          // Продолжаем обработку других отелей
        }
      }
      
      debugPrint('Успешно обработано ${hotels.length} отелей');
      
      // Если не получили результаты от API, возвращаем моковые данные
      if (hotels.isEmpty) {
        return MockData.getMockHotels();
      }
      
      return hotels;
    } catch (e) {
      debugPrint('Error getting hotels: $e');
      // В случае ошибки возвращаем моковые данные
      return MockData.getMockHotels();
    }
  }
  
  // Проверка и исправление обязательных полей в данных отеля
  void _validateAndFixHotelData(Map<String, dynamic> data) {
    // Проверяем id
    if (data['id'] == null) {
      data['id'] = 0;
      debugPrint('Отсутствует id, установлено значение по умолчанию');
    }
    
    // Проверяем place_id
    if (data['place_id'] == null) {
      data['place_id'] = 'unknown';
      debugPrint('Отсутствует place_id, установлено значение по умолчанию');
    }
    
    // Проверяем name
    if (data['name'] == null) {
      data['name'] = 'Unknown Hotel';
      debugPrint('Отсутствует name, установлено значение по умолчанию');
    }
    
    // Проверяем address
    if (data['address'] == null) {
      // Используем vicinity или name в качестве запасного варианта
      data['address'] = data['vicinity'] ?? data['name'] ?? 'Unknown Address';
      debugPrint('Отсутствует address, установлено значение по умолчанию: ${data['address']}');
    }
    
    // Проверяем latitude
    if (data['latitude'] == null) {
      data['latitude'] = 0.0;
      debugPrint('Отсутствует latitude, установлено значение по умолчанию');
    } else if (data['latitude'] is String) {
      // Преобразуем строку в число
      try {
        data['latitude'] = double.parse(data['latitude'] as String);
      } catch (e) {
        data['latitude'] = 0.0;
        debugPrint('Ошибка преобразования latitude из строки в число: $e');
      }
    }
    
    // Проверяем longitude
    if (data['longitude'] == null) {
      data['longitude'] = 0.0;
      debugPrint('Отсутствует longitude, установлено значение по умолчанию');
    } else if (data['longitude'] is String) {
      // Преобразуем строку в число
      try {
        data['longitude'] = double.parse(data['longitude'] as String);
      } catch (e) {
        data['longitude'] = 0.0;
        debugPrint('Ошибка преобразования longitude из строки в число: $e');
      }
    }
    
    // Проверяем created_at
    if (data['created_at'] == null) {
      data['created_at'] = DateTime.now().toIso8601String();
      debugPrint('Отсутствует created_at, установлено текущее время');
    }
    
    // Проверяем photos
    if (data['photos'] == null) {
      data['photos'] = [];
      debugPrint('Отсутствует photos, установлен пустой список');
    } else if (data['photos'] is List) {
      // Проверяем, что все элементы в списке photos - строки
      List<dynamic> photos = data['photos'] as List;
      for (int i = 0; i < photos.length; i++) {
        if (photos[i] == null) {
          photos[i] = 'https://via.placeholder.com/400x300?text=No+Image';
          debugPrint('Null-значение в photos[$i] заменено на заглушку');
        } else if (photos[i] is! String) {
          // Если элемент не является строкой, преобразуем его в строку
          photos[i] = photos[i].toString();
          debugPrint('Элемент photos[$i] преобразован в строку');
        }
      }
    } else {
      // Если photos не является списком, создаем пустой список
      data['photos'] = [];
      debugPrint('photos не является списком, установлен пустой список');
    }
    
    // Проверяем details
    if (data['details'] == null) {
      data['details'] = {};
      debugPrint('Отсутствует details, установлен пустой объект');
    } else if (data['details'] is! Map) {
      // Если details не является объектом, создаем пустой объект
      data['details'] = {};
      debugPrint('details не является объектом, установлен пустой объект');
    }
    
    // Проверяем rating
    if (data['rating'] != null) {
      if (data['rating'] is String) {
        // Преобразуем строку в число
        try {
          data['rating'] = double.parse(data['rating'] as String);
        } catch (e) {
          data['rating'] = null;
          debugPrint('Ошибка преобразования rating из строки в число: $e');
        }
      } else if (data['rating'] is! num) {
        // Если rating не является числом, устанавливаем null
        data['rating'] = null;
        debugPrint('rating не является числом, установлено null');
      }
    }
    
    // Проверяем user_ratings_total
    if (data['user_ratings_total'] != null) {
      if (data['user_ratings_total'] is String) {
        // Преобразуем строку в число
        try {
          data['user_ratings_total'] = int.parse(data['user_ratings_total'] as String);
        } catch (e) {
          data['user_ratings_total'] = null;
          debugPrint('Ошибка преобразования user_ratings_total из строки в число: $e');
        }
      } else if (data['user_ratings_total'] is! num) {
        // Если user_ratings_total не является числом, устанавливаем null
        data['user_ratings_total'] = null;
        debugPrint('user_ratings_total не является числом, установлено null');
      }
    }
  }
} 