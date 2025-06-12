import 'package:lastbooking/models/favorite.dart';
import 'api_service.dart';

class FavoriteService {
  final ApiService _apiService;

  FavoriteService(this._apiService);

  Future<List<Favorite>> getFavorites() async {
    final response = await _apiService.getList('/favorites');
    return response.map<Favorite>((json) => Favorite.fromJson(json)).toList();
  }

  Future<void> addToFavorites(int hotelId) async {
    await _apiService.post('/favorites', data: {'hotel_id': hotelId});
  }

  Future<void> removeFromFavorites(int favoriteId) async {
    await _apiService.delete('/favorites/$favoriteId');
  }

  Future<bool> isFavorite(int hotelId) async {
    try {
      final response = await _apiService.get('/favorites/check/$hotelId');
      return response['is_favorite'] ?? false;
    } catch (e) {
      return false;
    }
  }
} 