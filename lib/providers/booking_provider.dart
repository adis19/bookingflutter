import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/favorite.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  
  List<Booking> _bookings = [];
  List<Favorite> _favorites = [];
  Booking? _selectedBooking;
  bool _isLoading = false;
  String? _error;
  
  List<Booking> get bookings => _bookings;
  List<Favorite> get favorites => _favorites;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Создание нового бронирования
  Future<bool> createBooking({
    required String hotelId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guests,
    String? notes,
    Map<String, dynamic>? hotelData,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final booking = await _bookingService.createBooking(
        hotelId: hotelId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        guests: guests,
        notes: notes,
        hotelData: hotelData,
      );
      
      _bookings.add(booking);
      _selectedBooking = booking;
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Получение списка бронирований текущего пользователя
  Future<void> getMyBookings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _bookings = await _bookingService.getMyBookings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Получение информации о конкретном бронировании
  Future<void> getBooking(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _selectedBooking = await _bookingService.getBooking(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Обновление информации о бронировании
  Future<bool> updateBooking({
    required int id,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guests,
    String? status,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final updatedBooking = await _bookingService.updateBooking(
        id: id,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        guests: guests,
        status: status,
        notes: notes,
      );
      
      // Обновление в списке
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bookings[index] = updatedBooking;
      }
      
      if (_selectedBooking?.id == id) {
        _selectedBooking = updatedBooking;
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Отмена бронирования
  Future<bool> cancelBooking(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _bookingService.cancelBooking(id);
      
      // Обновление статуса в списке
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        final booking = _bookings[index];
        _bookings[index] = Booking(
          id: booking.id,
          userId: booking.userId,
          hotelId: booking.hotelId,
          checkInDate: booking.checkInDate,
          checkOutDate: booking.checkOutDate,
          guests: booking.guests,
          status: 'cancelled',
          notes: booking.notes,
          createdAt: booking.createdAt,
          hotel: booking.hotel,
        );
      }
      
      if (_selectedBooking?.id == id) {
        _selectedBooking = _bookings.firstWhere((b) => b.id == id);
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Удаление бронирования
  Future<bool> deleteBooking(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _bookingService.deleteBooking(id);
      
      _bookings.removeWhere((b) => b.id == id);
      
      if (_selectedBooking?.id == id) {
        _selectedBooking = null;
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Добавление отеля в избранное
  Future<bool> addToFavorites(int hotelId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final favorite = await _bookingService.addToFavorites(hotelId);
      _favorites.add(favorite);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Получение списка избранных отелей
  Future<void> getFavorites() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _favorites = await _bookingService.getFavorites();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Удаление отеля из избранного
  Future<bool> removeFromFavorites(int hotelId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _bookingService.removeFromFavorites(hotelId);
      
      _favorites.removeWhere((f) => f.hotelId == hotelId);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Проверка, находится ли отель в избранном
  bool isFavorite(int hotelId) {
    return _favorites.any((f) => f.hotelId == hotelId);
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 