import 'package:flutter/material.dart';
import 'package:lastbooking/models/favorite.dart';
import 'package:lastbooking/services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService;
  List<Favorite> _favorites = [];
  bool _isLoading = false;
  String? _error;

  FavoriteProvider(this._favoriteService);

  List<Favorite> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFavorites() async {
    _setLoading(true);
    try {
      _favorites = await _favoriteService.getFavorites();
      _error = null;
      
      // Отладочная информация о загруженных избранных
      debugPrint('Загружено ${_favorites.length} избранных отелей');
    } catch (e) {
      _error = 'Не удалось загрузить избранное: $e';
      debugPrint(_error!);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkIsFavorite(int hotelId) async {
    try {
      final result = await _favoriteService.isFavorite(hotelId);
      debugPrint('Отель $hotelId ${result ? "находится" : "не находится"} в избранном');
      return result;
    } catch (e) {
      debugPrint('Ошибка при проверке избранного: $e');
      return false;
    }
  }

  Future<void> addToFavorites(int hotelId) async {
    try {
      _setLoading(true);
      _error = null;
      
      // Сначала проверяем, не в избранном ли уже отель
      final isAlreadyFavorite = await checkIsFavorite(hotelId);
      if (isAlreadyFavorite) {
        debugPrint('Отель $hotelId уже в избранном, пропускаем добавление');
        _setLoading(false);
        return;
      }
      
      await _favoriteService.addToFavorites(hotelId);
      debugPrint('Отель $hotelId успешно добавлен в избранное');
      
      // Перезагружаем список избранного
      await loadFavorites();
    } catch (e) {
      _error = 'Не удалось добавить в избранное: $e';
      debugPrint(_error!);
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(int favoriteId) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _favoriteService.removeFromFavorites(favoriteId);
      debugPrint('Избранное с ID $favoriteId успешно удалено');
      
      // Удаляем из локального списка
      _favorites.removeWhere((favorite) => favorite.id == favoriteId);
      notifyListeners();
    } catch (e) {
      _error = 'Не удалось удалить из избранного: $e';
      debugPrint(_error!);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeHotelFromFavorites(int hotelId) async {
    try {
      _setLoading(true);
      _error = null;
      
      // Находим ID избранного по ID отеля
      final favorite = _favorites.firstWhere(
        (fav) => fav.hotelId == hotelId,
        orElse: () => throw Exception('Отель не найден в избранном'),
      );
      
      await removeFromFavorites(favorite.id);
    } catch (e) {
      _error = 'Не удалось удалить отель из избранного: $e';
      debugPrint(_error!);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
} 