import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lastbooking/models/admin_models.dart';
import 'package:lastbooking/models/user.dart';
import 'package:lastbooking/models/booking.dart';
import 'package:lastbooking/models/hotel.dart';

class AdminService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AdminService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://192.168.0.105:8000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));
  }

  // Получение списка всех пользователей
  Future<List<User>> getAllUsers() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('Не авторизован');
      }

      final response = await _dio.get(
        '/users',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      return (response.data as List)
          .map((user) => User.fromJson(user))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      // Возвращаем тестовые данные для демонстрации
      return _getMockUsers();
    }
  }

  // Получение списка всех бронирований
  Future<List<Booking>> getAllBookings() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('Не авторизован');
      }

      final response = await _dio.get(
        '/bookings',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      return (response.data as List)
          .map((booking) => Booking.fromJson(booking))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      // Возвращаем тестовые данные для демонстрации
      return _getMockBookings();
    }
  }

  // Получение статистики для админ-панели
  Future<AdminStats> getAdminStats() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('Не авторизован');
      }

      final response = await _dio.get(
        '/admin/stats',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      return AdminStats.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      // Возвращаем тестовые данные для демонстрации
      return AdminStats.mock();
    }
  }

  // Обработка ошибок
  void _handleError(DioException e) {
    if (e.response != null) {
      print('Error: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      print('Error: ${e.message}');
    }
  }

  // Тестовые данные для пользователей
  List<User> _getMockUsers() {
    return [
      User(
        id: 1,
        username: 'admin',
        email: 'admin@example.com',
        fullName: 'Администратор',
        phone: '+7 (999) 123-45-67',
        isAdmin: true,
        isActive: true,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
      ),
      User(
        id: 2,
        username: 'user1',
        email: 'user1@example.com',
        fullName: 'Иван Иванов',
        phone: '+7 (999) 111-22-33',
        isAdmin: false,
        isActive: true,
        createdAt: DateTime.now().subtract(Duration(days: 25)),
      ),
      User(
        id: 3,
        username: 'user2',
        email: 'user2@example.com',
        fullName: 'Мария Петрова',
        phone: '+7 (999) 444-55-66',
        isAdmin: false,
        isActive: true,
        createdAt: DateTime.now().subtract(Duration(days: 20)),
      ),
      User(
        id: 4,
        username: 'user3',
        email: 'user3@example.com',
        fullName: 'Алексей Сидоров',
        phone: '+7 (999) 777-88-99',
        isAdmin: false,
        isActive: false,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
      ),
    ];
  }

  // Тестовые данные для бронирований
  List<Booking> _getMockBookings() {
    final hotel1 = Hotel(
      id: 1,
      placeId: 'place1',
      name: 'Grand Plaza Hotel',
      address: 'Москва, ул. Тверская, 1',
      latitude: 55.7558,
      longitude: 37.6173,
      rating: 4.8,
      photos: ['https://example.com/hotel1.jpg'],
      userRatingsTotal: 120,
      createdAt: DateTime.now().subtract(Duration(days: 100)),
      details: {'price_level': 3},
    );
    
    final hotel2 = Hotel(
      id: 2,
      placeId: 'place2',
      name: 'Seaside Resort',
      address: 'Сочи, ул. Приморская, 10',
      latitude: 43.5992,
      longitude: 39.7257,
      rating: 4.5,
      photos: ['https://example.com/hotel2.jpg'],
      userRatingsTotal: 85,
      createdAt: DateTime.now().subtract(Duration(days: 100)),
      details: {'price_level': 4},
    );

    return [
      Booking(
        id: 1,
        userId: 2,
        hotelId: '1',
        hotel: hotel1,
        checkInDate: DateTime.now().add(Duration(days: 5)),
        checkOutDate: DateTime.now().add(Duration(days: 10)),
        guests: 2,
        totalPriceValue: 35000,
        status: 'confirmed',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
      Booking(
        id: 2,
        userId: 3,
        hotelId: '2',
        hotel: hotel2,
        checkInDate: DateTime.now().add(Duration(days: 7)),
        checkOutDate: DateTime.now().add(Duration(days: 14)),
        guests: 3,
        totalPriceValue: 42000,
        status: 'confirmed',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      Booking(
        id: 3,
        userId: 2,
        hotelId: '1',
        hotel: hotel1,
        checkInDate: DateTime.now().subtract(Duration(days: 10)),
        checkOutDate: DateTime.now().subtract(Duration(days: 5)),
        guests: 1,
        totalPriceValue: 18000,
        status: 'completed',
        createdAt: DateTime.now().subtract(Duration(days: 15)),
      ),
      Booking(
        id: 4,
        userId: 4,
        hotelId: '2',
        hotel: hotel2,
        checkInDate: DateTime.now().add(Duration(days: 20)),
        checkOutDate: DateTime.now().add(Duration(days: 25)),
        guests: 2,
        totalPriceValue: 28000,
        status: 'pending',
        createdAt: DateTime.now().subtract(Duration(hours: 12)),
      ),
    ];
  }
} 