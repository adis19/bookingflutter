import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Статический метод для получения токена (для ApiService)
  static String? getToken() {
    // Синхронный метод для возврата токена
    // Используется только в ApiService для заголовков запроса
    try {
      // Возвращаем null, так как мы не можем получить токен синхронно
      // В реальном приложении этот метод должен быть асинхронным
      return null;
    } catch (e) {
      print('Ошибка при получении токена: $e');
      return null;
    }
  }

  AuthService() {
    // Используем IP адрес компьютера в локальной сети
    String baseUrl = 'http://192.168.0.105:8000/api';
    try {
      if (dotenv.env.containsKey('API_URL')) {
        baseUrl = dotenv.env['API_URL']!;
      }
    } catch (e) {
      // Игнорируем ошибку, используем дефолтный URL
      print('Ошибка при чтении API_URL из .env в AuthService: $e');
    }

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));
  }

  // Регистрация нового пользователя
  Future<User> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'username': username,
        'password': password,
        'full_name': fullName,
        'phone': phone,
      });
      
      return User.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Авторизация пользователя
  Future<bool> login({required String username, required String password}) async {
    try {
      print('Попытка входа с логином: $username');
      
      // Используем простой Map
      final Map<String, dynamic> data = {
        'username': username,
        'password': password,
      };
      
      // Переопределяем базовые опции для этого запроса
      final dio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
      ));
      
      // Добавляем перехватчик для логирования запросов
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));

      final response = await dio.post(
        '/auth/token',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      print('Ответ от сервера: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        final token = response.data['access_token'];
        await _storage.write(key: 'access_token', value: token);
        print('Токен успешно сохранен');
        return true;
      } else {
        print('Ошибка при входе: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }

  // Получение информации о текущем пользователе
  Future<User> getCurrentUser() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('Не авторизован');
      }

      final response = await _dio.get(
        '/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      // Проверка и обработка полей перед созданием объекта User
      final userData = response.data;
      
      // Проверяем обязательные поля bool
      if (userData['is_active'] == null) {
        userData['is_active'] = true; // Значение по умолчанию
        print('Поле is_active отсутствует в ответе API, используем значение по умолчанию: true');
      }
      
      if (userData['is_admin'] == null) {
        userData['is_admin'] = false; // Значение по умолчанию
        print('Поле is_admin отсутствует в ответе API, используем значение по умолчанию: false');
      }
      
      // Проверяем дату создания
      if (userData['created_at'] == null) {
        userData['created_at'] = DateTime.now().toIso8601String();
        print('Поле created_at отсутствует в ответе API, используем текущую дату');
      }
      
      print('Данные пользователя перед созданием объекта: $userData');
      return User.fromJson(userData);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('Ошибка при получении данных пользователя: $e');
      rethrow;
    }
  }

  // Обновление профиля пользователя
  Future<User> updateProfile({
    required int userId,
    required String username,
    required String email,
    String? fullName,
    String? phone,
  }) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('Не авторизован');
      }

      final response = await _dio.put(
        '/users/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'username': username,
          'email': email,
          'full_name': fullName,
          'phone': phone,
        },
      );

      return User.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Выход из системы
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  // Проверка, авторизован ли пользователь
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  void _handleError(DioException e) {
    if (e.response != null) {
      print('Error: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      print('Error: ${e.message}');
    }
  }
} 