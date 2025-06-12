import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  late final String _apiKey;
  late final WeatherFactory _weatherFactory;
  final ApiService _apiService = ApiService();
  
  // Кэш для погоды Бишкека
  Weather? _bishkekWeatherCache;
  DateTime? _bishkekWeatherCacheTime;
  
  // Координаты Бишкека
  final double _bishkekLat = 42.8746;
  final double _bishkekLon = 74.5698;
  final String _bishkekName = 'Бишкек';
  
  // Флаг, указывающий, использовать ли бэкенд для получения погоды
  final bool useBackend = true; // Теперь эндпоинт готов, можно использовать бэкенд
  
  // OpenWeatherMap API ключ
  final String _openWeatherMapApiKey = 'f5cb0b965ea1364904a12bd98d0adae1';
  // Google Places API ключ
  final String _googlePlacesApiKey = 'D3zvlHL8F0ocFEASyCum3bPgDEk=';
  
  WeatherService() {
    // Используем API ключ OpenWeatherMap
    _apiKey = _openWeatherMapApiKey;
    try {
      // Пробуем прочитать из .env файла, если он существует
      if (dotenv.isInitialized && dotenv.env.containsKey('WEATHER_API_KEY')) {
        final envKey = dotenv.env['WEATHER_API_KEY'];
        if (envKey != null && envKey.isNotEmpty) {
          _apiKey = envKey;
          debugPrint('Используется API ключ погоды из .env файла');
        }
      }
    } catch (e) {
      debugPrint('Ошибка при чтении API ключа из .env файла: $e');
    }
    
    // Инициализируем WeatherFactory
    _weatherFactory = WeatherFactory(_apiKey, language: Language.RUSSIAN);
    
    // Предзагружаем погоду для Бишкека
    _prefetchBishkekWeather();
  }
  
  // Получение текущего местоположения
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Службы геолокации отключены');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Разрешения на местоположение отклонены');
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Разрешения на местоположение отклонены навсегда');
        return null;
      }
      
      // Если разрешение получено, определяем текущее местоположение с таймаутом
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10)
      );
      
      return position;
    } catch (e) {
      debugPrint('Ошибка при получении местоположения: $e');
      return null;
    }
  }
  
  // Получение города по координатам
  Future<String?> getCityFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, 
        longitude,
        localeIdentifier: 'ru_RU'
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locality = place.locality;
        final adminArea = place.administrativeArea;
        
        if (locality != null && locality.isNotEmpty) {
          return locality;
        } else if (adminArea != null && adminArea.isNotEmpty) {
          return adminArea;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Ошибка при получении города по координатам: $e');
      return null;
    }
  }
  
  // Предварительная загрузка погоды для Бишкека
  Future<void> _prefetchBishkekWeather() async {
    try {
      final bishkekWeather = await getWeatherByCity(_bishkekName);
      _bishkekWeatherCache = bishkekWeather;
      _bishkekWeatherCacheTime = DateTime.now();
      debugPrint('Погода для Бишкека предзагружена успешно');
    } catch (e) {
      debugPrint('Ошибка при предзагрузке погоды для Бишкека: $e');
    }
  }
  
  // Проверка, актуален ли кэш (не старше 30 минут)
  bool _isCacheValid() {
    if (_bishkekWeatherCache == null || _bishkekWeatherCacheTime == null) {
      return false;
    }
    
    final difference = DateTime.now().difference(_bishkekWeatherCacheTime!);
    return difference.inMinutes < 30;
  }
  
  /// Получение погоды через бэкенд
  Future<Weather> _getWeatherFromBackend(String cityName, {double? latitude, double? longitude}) async {
    try {
      final queryParams = <String, dynamic>{};
      
      // Если переданы координаты, добавляем их в запрос
      if (latitude != null && longitude != null) {
        queryParams['lat'] = latitude.toString();
        queryParams['lon'] = longitude.toString();
      } else if (cityName.isNotEmpty) {
        // Иначе используем название города
        queryParams['city'] = cityName;
      }
      
      debugPrint('🌤️ Запрос погоды через бэкенд для ${cityName.isNotEmpty ? cityName : "координат $latitude, $longitude"}');
      
      try {
        // Используем API сервис для обращения к бэкенду с правильным путем
        final response = await _apiService.get('/weather', queryParameters: queryParams);
        debugPrint('✅ Получен ответ от бэкенда: ${response.toString().substring(0, min(100, response.toString().length))}...');
        
        // Проверяем, что ответ содержит необходимые данные
        if (response is Map && 
            response.containsKey('weather') && 
            response.containsKey('main') && 
            response.containsKey('name')) {
          
          // Получаем имя города из ответа
          final locationName = response['name'] as String? ?? cityName;
          
          // Преобразуем Map<dynamic, dynamic> в Map<String, dynamic>
          final weatherData = <String, dynamic>{};
          response.forEach((key, value) {
            if (key is String) {
              weatherData[key] = value;
            }
          });
          
          // Создаем объект Weather с преобразованными данными
          return Weather(weatherData);
        } else {
          throw Exception('Ответ от бэкенда не содержит необходимых данных о погоде');
        }
      } catch (e) {
        debugPrint('❌ Ошибка при получении погоды через бэкенд: $e');
        debugPrint('⚠️ Переключение на прямой запрос к OpenWeatherMap API');
        
        // Если не удалось получить погоду через бэкенд, используем прямой запрос
        if (latitude != null && longitude != null) {
          return await _getWeatherFromOpenWeatherMap(latitude: latitude, longitude: longitude);
        } else {
          return await _getWeatherFromOpenWeatherMap(cityName: cityName);
        }
      }
    } catch (e) {
      debugPrint('❌ Общая ошибка погодного сервиса: $e');
      
      // Если все методы не сработали, возвращаем заглушку
      return _createFallbackWeather();
    }
  }
  
  /// Получение погоды напрямую от OpenWeatherMap
  Future<Weather> _getWeatherFromOpenWeatherMap({String? cityName, double? latitude, double? longitude}) async {
    try {
      debugPrint('🌐 Прямой запрос к OpenWeatherMap API');
      
      if (latitude != null && longitude != null) {
        final weather = await _weatherFactory.currentWeatherByLocation(latitude, longitude);
        debugPrint('✅ Погода по координатам получена от OpenWeatherMap');
        return weather;
      } else if (cityName != null && cityName.isNotEmpty) {
        final weather = await _weatherFactory.currentWeatherByCityName(cityName);
        debugPrint('✅ Погода для города $cityName получена от OpenWeatherMap');
        return weather;
      } else {
        // Если не переданы ни координаты, ни город, используем Бишкек
        final weather = await _weatherFactory.currentWeatherByCityName(_bishkekName);
        debugPrint('✅ Погода для Бишкека получена от OpenWeatherMap (запасной вариант)');
      return weather;
      }
    } catch (e) {
      debugPrint('❌ Ошибка при прямом запросе к OpenWeatherMap: $e');
      
      // Если это не Бишкек, пробуем получить погоду для Бишкека
      if ((cityName == null || cityName != _bishkekName) && 
          (latitude == null || longitude == null || 
           (latitude - _bishkekLat).abs() > 0.1 || 
           (longitude - _bishkekLon).abs() > 0.1)) {
        return await _getWeatherFromOpenWeatherMap(cityName: _bishkekName);
      }
      
      // Если все методы не сработали, возвращаем заглушку
      return _createFallbackWeather();
    }
  }
  
  // Конвертация данных из формата WeatherAPI.com в формат OpenWeatherMap
  Map<String, dynamic> _convertWeatherApiToOpenWeatherMap(Map<String, dynamic> weatherApiData) {
    final current = weatherApiData['current'] ?? {};
    final location = weatherApiData['location'] ?? {};
    final condition = current['condition'] ?? {};
    
    // Преобразуем код погоды и подготовим иконку
    final conditionText = condition['text'] ?? '';
    final isDay = current['is_day'] == 1;
    
    // Создаем данные в формате OpenWeatherMap
    return {
      'coord': {
        'lon': location['lon'] ?? 0.0,
        'lat': location['lat'] ?? 0.0
      },
      'weather': [
        {
          'id': 800, // По умолчанию ясно
          'main': 'Clear',
          'description': conditionText.toLowerCase(),
          'icon': isDay ? '01d' : '01n' // Базовая иконка
        }
      ],
      'base': 'stations',
      'main': {
        'temp': current['temp_c'] ?? 0.0,
        'feels_like': current['feelslike_c'] ?? 0.0,
        'temp_min': (current['temp_c'] ?? 0.0) - 1.0,
        'temp_max': (current['temp_c'] ?? 0.0) + 1.0,
        'pressure': current['pressure_mb'] ?? 1013.0,
        'humidity': current['humidity'] ?? 0
      },
      'visibility': (current['vis_km'] ?? 10.0) * 1000,
      'wind': {
        'speed': (current['wind_kph'] ?? 0.0) / 3.6, // конвертируем км/ч в м/с
        'deg': current['wind_degree'] ?? 0
      },
      'clouds': {
        'all': current['cloud'] ?? 0
      },
      'dt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'sys': {
        'country': location['country'] ?? '',
        'sunrise': DateTime.now().subtract(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000,
        'sunset': DateTime.now().add(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000
      },
      'timezone': 0,
      'id': 0,
      'name': location['name'] ?? 'Unknown',
      'cod': 200
    };
  }
  
  /// Получение погоды по названию города
  Future<Weather> getWeatherByCity(String cityName) async {
    if (cityName.isEmpty) {
      cityName = _bishkekName;
    }
    
    // Если запрашивается Бишкек и есть валидный кэш, используем его
    if (cityName.toLowerCase() == _bishkekName.toLowerCase() && _isCacheValid()) {
      debugPrint('Используем кэшированную погоду для Бишкека');
      return _bishkekWeatherCache!;
    }
    
    try {
      // Если нужно использовать бэкенд
      if (useBackend) {
        return await _getWeatherFromBackend(cityName);
      }
      
      // Иначе используем прямой запрос к API
      return await _getWeatherFromOpenWeatherMap(cityName: cityName);
    } catch (e) {
      debugPrint('Ошибка при получении погоды для города $cityName: $e');
      
      // Если запрашивали не Бишкек, пробуем получить погоду для Бишкека
      if (cityName.toLowerCase() != _bishkekName.toLowerCase()) {
        debugPrint('Пробуем получить погоду для Бишкека вместо $cityName');
        return getWeatherByCity(_bishkekName);
      }
      
      // Если есть кэш (даже устаревший), используем его
      if (_bishkekWeatherCache != null) {
        debugPrint('Используем устаревшую кэшированную погоду для Бишкека');
        return _bishkekWeatherCache!;
      }
      
      // Если все методы не сработали, возвращаем заглушку
      return _createFallbackWeather();
    }
  }
  
  /// Получение погоды по координатам
  Future<Weather> getWeatherByLocation(double latitude, double longitude) async {
    try {
      // Если координаты близки к Бишкеку и есть валидный кэш, используем его
      if (_isNearBishkek(latitude, longitude) && _isCacheValid()) {
        debugPrint('Координаты близки к Бишкеку, используем кэшированную погоду');
        return _bishkekWeatherCache!;
      }
      
      // Если нужно использовать бэкенд
      if (useBackend) {
        return await _getWeatherFromBackend(_bishkekName, latitude: latitude, longitude: longitude);
    }
      
      // Иначе используем прямой запрос к API
      return await _getWeatherFromOpenWeatherMap(latitude: latitude, longitude: longitude);
    } catch (e) {
      debugPrint('Ошибка при получении погоды по координатам: $e');
      return getBishkekWeather();
    }
  }
  
  /// Получение погоды для Бишкека (с гарантированным результатом)
  Future<Weather> getBishkekWeather() async {
    try {
      return await getWeatherByCity(_bishkekName);
    } catch (e) {
      debugPrint('Ошибка при получении погоды для Бишкека: $e');
      
      try {
        // Пробуем получить погоду для Бишкека по координатам
        return await getWeatherByLocation(_bishkekLat, _bishkekLon);
      } catch (e2) {
        debugPrint('Ошибка при получении погоды для Бишкека по координатам: $e2');
        
        // Если есть кэш (даже устаревший), используем его
        if (_bishkekWeatherCache != null) {
          debugPrint('Используем устаревшую кэшированную погоду для Бишкека');
          return _bishkekWeatherCache!;
        }
        
        // Если все методы не сработали, возвращаем заглушку
        return _createFallbackWeather();
      }
    }
  }
  
  // Создание заглушки погоды для Бишкека
  Weather _createFallbackWeather() {
    debugPrint('Создаю заглушку погоды для Бишкека');
    
    // Создаем Map с данными о погоде
    final Map<String, dynamic> weatherData = {
      'name': _bishkekName,
      'main': {
        'temp': 299.15, // 26°C в Кельвинах (273.15 + 26 = 299.15)
        'humidity': 50,
      },
      'weather': [
        {
          'id': 803, // Облачно (код между 801-804 для разной степени облачности)
          'main': 'Clouds',
          'description': 'Облачно',
          'icon': '03d'
        }
      ],
      'wind': {
        'speed': 2.0,
        'deg': 0
      },
      'dt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'sys': {
        'sunrise': DateTime.now().subtract(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000,
        'sunset': DateTime.now().add(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000
      },
      'clouds': {
        'all': 75 // 75% облачности
      }
    };
    
    // Используем конструктор, принимающий Map
    return Weather(weatherData);
  }
  
  // Проверка, находятся ли координаты рядом с Бишкеком
  bool _isNearBishkek(double latitude, double longitude) {
    return (latitude - _bishkekLat).abs() < 0.1 && (longitude - _bishkekLon).abs() < 0.1;
  }
  
  /// Получение иконки погоды
  String getWeatherIcon(int conditionCode) {
    // Коды WeatherCondition из библиотеки weather
    if (conditionCode >= 200 && conditionCode < 300) {
      return '⛈️'; // Гроза
    } else if (conditionCode >= 300 && conditionCode < 400) {
      return '🌧️'; // Морось
    } else if (conditionCode >= 500 && conditionCode < 600) {
      return '🌧️'; // Дождь
    } else if (conditionCode >= 600 && conditionCode < 700) {
      return '❄️'; // Снег
    } else if (conditionCode >= 700 && conditionCode < 800) {
      return '🌫️'; // Туман
    } else if (conditionCode == 800) {
      return '☀️'; // Ясно
    } else if (conditionCode > 800 && conditionCode < 900) {
      return '☁️'; // Облачно
    } else {
      return '🌡️'; // По умолчанию
    }
  }
  
  /// Получение описания погоды на русском языке
  String getWeatherDescription(int conditionCode) {
    if (conditionCode >= 200 && conditionCode < 300) {
      return 'Гроза';
    } else if (conditionCode >= 300 && conditionCode < 400) {
      return 'Морось';
    } else if (conditionCode >= 500 && conditionCode < 600) {
      return 'Дождь';
    } else if (conditionCode >= 600 && conditionCode < 700) {
      return 'Снег';
    } else if (conditionCode >= 700 && conditionCode < 800) {
      return 'Туман';
    } else if (conditionCode == 800) {
      return 'Ясно';
    } else if (conditionCode > 800 && conditionCode < 900) {
      return 'Облачно';
    } else {
      return 'Неизвестно';
    }
  }
}

// Helper function
int min(int a, int b) {
  return a < b ? a : b;
} 