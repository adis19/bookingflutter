import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/favorite.dart';
import '../models/hotel.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _apiService = ApiService();

  // Создание нового бронирования
  Future<Booking> createBooking({
    required String hotelId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guests,
    String? notes,
    Map<String, dynamic>? hotelData,
  }) async {
    try {
      debugPrint('Создаем новое бронирование отеля $hotelId');
      
      final data = {
        'hotel_id': hotelId,
        'check_in_date': checkInDate.toIso8601String().split('T')[0],
        'check_out_date': checkOutDate.toIso8601String().split('T')[0],
        'guests': guests,
      };
      
      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }
      
      // Если переданы дополнительные данные отеля для моковых данных
      if (hotelData != null) {
        data['hotelData'] = hotelData;
      }
      
      final response = await _apiService.post('/bookings', data: data);
      debugPrint('Бронирование успешно создано: ${response['id']}');
      
      return Booking.fromJson(response);
    } catch (e) {
      debugPrint('Ошибка при создании бронирования: $e');
      rethrow;
    }
  }

  // Получение списка бронирований текущего пользователя
  Future<List<Booking>> getMyBookings() async {
    try {
      debugPrint('Загрузка списка бронирований...');
      final response = await _apiService.getList('/bookings/my');
      
      debugPrint('Получено ${response.length} бронирований');
      final bookings = response.map<Booking>((item) {
        try {
          // Добавляем проверку на наличие данных отеля
          if (!item.containsKey('hotel') || item['hotel'] == null) {
            // Если данные отеля отсутствуют, создаем объект Booking без отеля
            debugPrint('Отсутствуют данные отеля для бронирования с ID: ${item['id']}');
            return Booking(
              id: item['id'],
              userId: item['user_id'],
              hotelId: item['hotel_id'],
              checkInDate: DateTime.parse(item['check_in_date']),
              checkOutDate: DateTime.parse(item['check_out_date']),
              guests: item['guests'],
              status: item['status'],
              notes: item['notes'],
              createdAt: DateTime.parse(item['created_at']),
              hotel: null,
              totalPriceValue: item['total_price'],
            );
          }
          
          return Booking.fromJson(item);
        } catch (e) {
          debugPrint('Ошибка при преобразовании бронирования: $e');
          // Создаем объект Booking с минимальными данными в случае ошибки
          return Booking(
            id: item['id'] ?? 0,
            userId: item['user_id'] ?? 0,
            hotelId: item['hotel_id'] ?? '',
            checkInDate: item['check_in_date'] != null 
                ? DateTime.parse(item['check_in_date']) 
                : DateTime.now(),
            checkOutDate: item['check_out_date'] != null 
                ? DateTime.parse(item['check_out_date']) 
                : DateTime.now().add(const Duration(days: 1)),
            guests: item['guests'] ?? 1,
            status: item['status'] ?? 'error',
            notes: item['notes'],
            createdAt: item['created_at'] != null 
                ? DateTime.parse(item['created_at']) 
                : DateTime.now(),
            hotel: null,
          );
        }
      }).toList();
      
      // В режиме отладки, если список пуст, возвращаем моковые данные независимо от условий
      if (kDebugMode) {
        if (bookings.isEmpty) {
          debugPrint('Список бронирований пуст, возвращаем моковые данные');
          return _getMockBookings();
        }
      }
      
      return bookings;
    } catch (e) {
      debugPrint('Ошибка при получении бронирований: $e');
      if (kDebugMode) {
        // В режиме отладки возвращаем моковые данные
        return _getMockBookings();
      }
      // В производственном режиме пробрасываем ошибку
      rethrow;
    }
  }

  // Получение информации о конкретном бронировании
  Future<Booking> getBooking(int id) async {
    try {
      final response = await _apiService.get('/bookings/$id');
      return Booking.fromJson(response);
    } catch (e) {
      debugPrint('Ошибка при получении бронирования: $e');
      rethrow;
    }
  }

  // Обновление информации о бронировании
  Future<Booking> updateBooking({
    required int id,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guests,
    String? status,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (checkInDate != null) {
        data['check_in_date'] = checkInDate.toIso8601String().split('T')[0];
      }
      
      if (checkOutDate != null) {
        data['check_out_date'] = checkOutDate.toIso8601String().split('T')[0];
      }
      
      if (guests != null) {
        data['guests'] = guests;
      }
      
      if (status != null) {
        data['status'] = status;
      }
      
      if (notes != null) {
        data['notes'] = notes;
      }
      
      final response = await _apiService.put('/bookings/$id', data: data);
      return Booking.fromJson(response);
    } catch (e) {
      debugPrint('Ошибка при обновлении бронирования: $e');
      rethrow;
    }
  }

  // Отмена бронирования
  Future<void> cancelBooking(int id) async {
    try {
      await _apiService.post('/bookings/$id/cancel');
    } catch (e) {
      debugPrint('Ошибка при отмене бронирования: $e');
      rethrow;
    }
  }

  // Удаление бронирования
  Future<void> deleteBooking(int id) async {
    try {
      await _apiService.delete('/bookings/$id');
    } catch (e) {
      debugPrint('Ошибка при удалении бронирования: $e');
      rethrow;
    }
  }

  // Добавление отеля в избранное
  Future<Favorite> addToFavorites(int hotelId) async {
    try {
      final response = await _apiService.post('/favorites', data: {'hotel_id': hotelId});
      return Favorite.fromJson(response);
    } catch (e) {
      debugPrint('Ошибка при добавлении в избранное: $e');
      rethrow;
    }
  }

  // Получение списка избранных отелей
  Future<List<Favorite>> getFavorites() async {
    try {
      final response = await _apiService.getList('/favorites');
      return response.map<Favorite>((json) => Favorite.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Ошибка при получении избранных отелей: $e');
      return [];
    }
  }

  // Удаление отеля из избранного
  Future<void> removeFromFavorites(int hotelId) async {
    try {
      await _apiService.delete('/favorites/$hotelId');
    } catch (e) {
      debugPrint('Ошибка при удалении из избранного: $e');
      rethrow;
    }
  }

  // Создание моковых данных для отладки
  List<Booking> _getMockBookings() {
    debugPrint('Создание моковых бронирований');
    
    final mockHotel1 = Hotel(
      id: 1,
      placeId: 'mock_place_id_1',
      name: 'Отель Хаятт',
      address: 'ул. Примерная, 123',
      latitude: 42.87,
      longitude: 74.59,
      rating: 4.7,
      userRatingsTotal: 129,
      createdAt: DateTime.now(),
      placeTypeString: 'hotel',
    );
    
    final mockHotel2 = Hotel(
      id: 2,
      placeId: 'mock_place_id_2',
      name: 'Бишкек Плаза',
      address: 'ул. Центральная, 456',
      latitude: 42.86,
      longitude: 74.58,
      rating: 4.3,
      userRatingsTotal: 98,
      createdAt: DateTime.now(),
      placeTypeString: 'hotel',
    );
    
    final now = DateTime.now();
    
    return [
      Booking(
        id: 1,
        userId: 1,
        hotelId: 'mock_place_id_1',
        checkInDate: now.add(const Duration(days: 5)),
        checkOutDate: now.add(const Duration(days: 8)),
        guests: 2,
        status: 'confirmed',
        notes: 'Прошу номер с видом на горы',
        createdAt: now.subtract(const Duration(days: 2)),
        hotel: mockHotel1,
        totalPriceValue: 15000,
      ),
      Booking(
        id: 2,
        userId: 1,
        hotelId: 'mock_place_id_2',
        checkInDate: now.add(const Duration(days: 15)),
        checkOutDate: now.add(const Duration(days: 20)),
        guests: 3,
        status: 'pending',
        notes: null,
        createdAt: now.subtract(const Duration(days: 1)),
        hotel: mockHotel2,
        totalPriceValue: 25000,
      ),
      // Бронирование без отеля для тестирования обработки null
      Booking(
        id: 3,
        userId: 1,
        hotelId: 'non_existent_id',
        checkInDate: now.add(const Duration(days: 30)),
        checkOutDate: now.add(const Duration(days: 35)),
        guests: 1,
        status: 'confirmed',
        notes: null,
        createdAt: now,
        hotel: null,
        totalPriceValue: 10000,
      ),
    ];
  }
} 