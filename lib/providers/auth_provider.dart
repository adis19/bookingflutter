import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  List<int> _tempFavorites = [];
  
  // В режиме отладки НЕ считаем пользователя автоматически авторизованным
  bool get isAuthenticated => _user != null;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _user?.isAdmin ?? false;
  
  // Геттер для получения избранных для неавторизованных пользователей
  List<int> get tempFavorites => _tempFavorites;
  
  AuthProvider() {
    _checkAuth();
    _loadTempFavorites();
  }
  
  // Загрузка временных избранных из локального хранилища
  Future<void> _loadTempFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? tempFavoriteStrings = prefs.getStringList('temp_favorites');
      
      if (tempFavoriteStrings != null) {
        _tempFavorites = tempFavoriteStrings.map((e) => int.parse(e)).toList();
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке временных избранных: $e');
    }
  }
  
  // Сохранение временных избранных в локальное хранилище
  Future<void> _saveTempFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'temp_favorites', 
        _tempFavorites.map((e) => e.toString()).toList()
      );
    } catch (e) {
      debugPrint('Ошибка при сохранении временных избранных: $e');
    }
  }
  
  // Добавление в избранное для неавторизованного пользователя
  Future<void> addToTempFavorites(int hotelId) async {
    if (!_tempFavorites.contains(hotelId)) {
      _tempFavorites.add(hotelId);
      await _saveTempFavorites();
      notifyListeners();
    }
  }
  
  // Удаление из избранного для неавторизованного пользователя
  Future<void> removeFromTempFavorites(int hotelId) async {
    if (_tempFavorites.contains(hotelId)) {
      _tempFavorites.remove(hotelId);
      await _saveTempFavorites();
      notifyListeners();
    }
  }
  
  // Проверка, в избранном ли отель для неавторизованного пользователя
  bool isInTempFavorites(int hotelId) {
    return _tempFavorites.contains(hotelId);
  }
  
  // Перенос временных избранных в базу данных при авторизации
  Future<void> _transferTempFavorites() async {
    // Эта функция должна быть реализована в случае реальной поддержки временных избранных
    // В текущем демо-режиме это не требуется
  }
  
  // Проверка статуса аутентификации
  Future<void> _checkAuth() async {
    try {
      _setLoading(true);
      _clearError();
      
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        _user = await _authService.getCurrentUser();
        debugPrint('Пользователь ${_user?.username} авторизован');
      } else {
        _user = null;
        debugPrint('Пользователь не авторизован');
      }
    } catch (e) {
      _setError('Ошибка при проверке авторизации: $e');
      _user = null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
  
  // Авторизация
  Future<bool> login(String username, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _authService.login(username: username, password: password);
      
      if (success) {
        _user = await _authService.getCurrentUser();
        // Переносим временные избранные в базу данных
        await _transferTempFavorites();
        debugPrint('Пользователь ${_user?.username} успешно вошел в систему');
      } else {
        _setError('Неверное имя пользователя или пароль');
        _user = null;
      }
      
      return success;
    } catch (e) {
      _setError('Ошибка авторизации: $e');
      _user = null;
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
  
  // Регистрация
  Future<bool> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _authService.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      
      // После успешной регистрации входим в систему
      final success = await _authService.login(username: username, password: password);
      
      if (success) {
        _user = user;
        // Переносим временные избранные в базу данных
        await _transferTempFavorites();
        debugPrint('Пользователь ${_user?.username} успешно зарегистрирован и вошел в систему');
      } else {
        _setError('Не удалось войти после регистрации');
        _user = null;
      }
      
      return success;
    } catch (e) {
      _setError('Ошибка регистрации: $e');
      _user = null;
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
  
  // Выход из системы
  Future<void> logout() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.logout();
      _user = null;
      // Очищаем временные избранные при выходе
      _tempFavorites = [];
      await _saveTempFavorites();
      debugPrint('Пользователь вышел из системы');
    } catch (e) {
      _setError('Ошибка при выходе из системы: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
      
  // Обновление профиля
  Future<bool> updateProfile({
    required String username,
    required String email,
    String? fullName,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_user == null) {
        _setError('Пользователь не авторизован');
        return false;
      }
      
      final updatedUser = await _authService.updateProfile(
        userId: _user!.id,
        username: username,
        email: email,
        fullName: fullName,
        phone: phone,
      );
      
      _user = updatedUser;
      debugPrint('Профиль пользователя ${_user?.username} обновлен');
      
      return true;
    } catch (e) {
      _setError('Ошибка при обновлении профиля: $e');
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
  
  // Повторная проверка статуса аутентификации
  Future<void> checkAuth() async {
    await _checkAuth();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
  }
  
  void _setError(String? errorMessage) {
    _error = errorMessage;
    debugPrint('AuthProvider error: $_error');
  }
  
  void _clearError() {
    _error = null;
  }
} 