import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/hotel.dart';
import '../models/favorite.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HotelCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback onTap;
  final bool showFavoriteButton;

  const HotelCard({
    Key? key,
    required this.hotel,
    required this.onTap,
    this.showFavoriteButton = true,
  }) : super(key: key);

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool _isFavorite = false;
  bool _isLoading = false;
  int? _favoriteId;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
      await favoriteProvider.loadFavorites();
      
      if (mounted) {
        // Ищем отель в списке избранного
        final favorite = favoriteProvider.favorites.firstWhere(
          (fav) => fav.hotelId == widget.hotel.id,
          orElse: () => Favorite(
            id: -1,
            userId: -1,
            hotelId: -1,
            createdAt: DateTime.now(),
            hotel: null,
          ),
        );
        
        setState(() {
          _isFavorite = favorite.id != -1;
          _favoriteId = _isFavorite ? favorite.id : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ошибка при проверке избранного: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _toggleFavorite() async {
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      // Показываем диалог с предложением авторизоваться
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Требуется авторизация',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Для добавления отеля в избранное необходимо войти в аккаунт.',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Отмена',
                style: GoogleFonts.montserrat(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
              ),
              child: Text(
                'Войти',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_isFavorite) {
        // Удаляем из избранного (используем ID избранного)
        await favoriteProvider.removeFromFavorites(_favoriteId!);
        setState(() {
          _isFavorite = false;
          _favoriteId = null;
        });
      } else {
        // Добавляем в избранное (передаем ID отеля вместо объекта Hotel)
        await favoriteProvider.addToFavorites(widget.hotel.id);
        setState(() {
          _isFavorite = true;
          // _favoriteId будет установлен при следующей проверке
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite 
                ? 'Отель добавлен в избранное' 
                : 'Отель удален из избранного',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: AppConstants.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка: $e',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение отеля с иконкой и ценовой категорией
            Stack(
              children: [
                // Основное изображение
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: (widget.hotel.photos != null && widget.hotel.photos!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: widget.hotel.photos!.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.hotel,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            widget.hotel.placeType == 'restaurant'
                                ? Icons.restaurant
                                : Icons.hotel,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                ),
                
                // Кнопка избранного
                if (widget.showFavoriteButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _toggleFavorite,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 26,
                                  color: _isFavorite
                                      ? Colors.red
                                      : Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                
                // Иконка отеля или ресторана
                if (widget.hotel.icon != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.hotel.iconBackgroundColor != null 
                            ? Color(int.parse('0xFF${widget.hotel.iconBackgroundColor!.substring(1)}'))
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.hotel.icon!,
                        width: 24,
                        height: 24,
                        placeholder: (context, url) => const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          widget.hotel.placeType == 'restaurant'
                              ? Icons.restaurant
                              : Icons.hotel,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                
                // Ценовая категория
                if (widget.hotel.priceLevel != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$' * widget.hotel.priceLevel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Информация об отеле
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название отеля
                  Text(
                    widget.hotel.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Адрес
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        widget.hotel.placeType == 'restaurant'
                            ? Icons.location_on
                            : Icons.hotel,
                        size: 16,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.hotel.vicinity ?? widget.hotel.address ?? 'Адрес неизвестен',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Типы отеля
                  if (widget.hotel.types != null && widget.hotel.types!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: widget.hotel.types!.take(3).map((type) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  // Рейтинг и количество отзывов
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      if (widget.hotel.rating != null) ...[
                        RatingBar.builder(
                          initialRating: widget.hotel.rating!,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 16,
                          ignoreGestures: true,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {},
                        ),
                        Text(
                          widget.hotel.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      
                      // Количество отзывов
                      if (widget.hotel.userRatingsTotal != null)
                        Text(
                          '(${widget.hotel.userRatingsTotal} ${_getPluralForm(widget.hotel.userRatingsTotal!)})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getPluralForm(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'отзыв';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'отзыва';
    } else {
      return 'отзывов';
    }
  }
} 