import 'package:flutter/material.dart';
import 'package:lastbooking/models/admin_models.dart';
import 'package:lastbooking/models/booking.dart';
import 'package:lastbooking/models/user.dart';
import 'package:lastbooking/services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  
  List<User>? _users;
  List<Booking>? _bookings;
  AdminStats? _stats;
  
  bool _isLoadingUsers = false;
  bool _isLoadingBookings = false;
  bool _isLoadingStats = false;
  
  String? _error;
  
  // Геттеры
  List<User> get users => _users ?? [];
  List<Booking> get bookings => _bookings ?? [];
  AdminStats? get stats => _stats;
  
  bool get isLoadingUsers => _isLoadingUsers;
  bool get isLoadingBookings => _isLoadingBookings;
  bool get isLoadingStats => _isLoadingStats;
  
  bool get isLoading => _isLoadingUsers || _isLoadingBookings || _isLoadingStats;
  String? get error => _error;
  
  // Загрузка пользователей
  Future<void> loadUsers() async {
    try {
      _isLoadingUsers = true;
      _error = null;
      notifyListeners();
      
      _users = await _adminService.getAllUsers();
    } catch (e) {
      _error = 'Ошибка при загрузке пользователей: $e';
      debugPrint(_error);
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }
  
  // Загрузка бронирований
  Future<void> loadBookings() async {
    try {
      _isLoadingBookings = true;
      _error = null;
      notifyListeners();
      
      _bookings = await _adminService.getAllBookings();
    } catch (e) {
      _error = 'Ошибка при загрузке бронирований: $e';
      debugPrint(_error);
    } finally {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }
  
  // Загрузка статистики
  Future<void> loadStats() async {
    try {
      _isLoadingStats = true;
      _error = null;
      notifyListeners();
      
      _stats = await _adminService.getAdminStats();
    } catch (e) {
      _error = 'Ошибка при загрузке статистики: $e';
      debugPrint(_error);
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }
  
  // Загрузка всех данных
  Future<void> loadAllData() async {
    _error = null;
    await Future.wait([
      loadUsers(),
      loadBookings(),
      loadStats(),
    ]);
  }
  
  // Очистка ошибок
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 