import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../models/hotel.dart';
import '../../models/favorite.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/booking_provider.dart';
import '../bookings/create_booking_screen.dart';
import '../auth/login_screen.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  bool _isProcessing = false;
  List<String> _photos = [];
  int? _favoriteId;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkFavoriteStatus();
    _loadPhotos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPhotos() {
    setState(() {
      _photos = widget.hotel.photos ?? [];
    });
  }

  Future<void> _checkFavoriteStatus() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingFavorite = true;
    });
    
    try {
      final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
      await favoriteProvider.loadFavorites();
      
      if (!mounted) return;
      
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
        _isLoadingFavorite = false;
      });
    } catch (e) {
      debugPrint('Ошибка при проверке избранного: $e');
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });
      }
    }
  }

  void _toggleFavorite() async {
    if (!mounted) return;
    
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      // Показываем диалог с предложением авторизоваться
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppConstants.primaryColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Иконка
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Заголовок
                Text(
                  'Требуется авторизация',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Описание
                Text(
                  'Для добавления отеля в избранное необходимо войти в аккаунт.',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: AppConstants.secondaryTextColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Кнопки
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppConstants.secondaryTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Отмена',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: AppConstants.primaryColor.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Войти',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      if (_isFavorite) {
        // Удаляем из избранного
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
      
      // Показываем сообщение
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
        _isLoadingFavorite = false;
        });
    }
  }

  Future<void> _openMap() async {
    try {
      final url = 'https://www.google.com/maps/search/?api=1&query=${widget.hotel.latitude},${widget.hotel.longitude}';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось открыть карту')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при открытии карты: $e')),
        );
      }
    }
  }

  Future<void> _makePhoneCall() async {
    try {
      final phoneNumber = widget.hotel.phoneNumber;
      if (phoneNumber == null || phoneNumber.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Номер телефона недоступен')),
          );
        }
        return;
      }

      final url = 'tel:$phoneNumber';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось совершить звонок')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при совершении звонка: $e')),
        );
      }
    }
  }

  Future<void> _openWebsite() async {
    try {
      final website = widget.hotel.website;
      if (website == null || website.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Веб-сайт недоступен')),
          );
        }
        return;
      }

      final uri = Uri.parse(website);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось открыть веб-сайт')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при открытии веб-сайта: $e')),
        );
      }
    }
  }

  void _navigateToBooking() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      _showAuthRequiredDialog('бронирования');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBookingScreen(hotel: widget.hotel),
      ),
    );
  }

  void _showAuthRequiredDialog(String action) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppConstants.primaryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  action == 'бронирования' ? Icons.hotel_rounded : Icons.login_rounded,
                  size: 40,
                  color: AppConstants.primaryColor,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Заголовок
              Text(
                'Требуется авторизация',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Описание
              Text(
                'Для $action необходимо войти в систему или зарегистрироваться.',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: AppConstants.secondaryTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppConstants.secondaryTextColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Отмена',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: AppConstants.primaryColor.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Войти',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String placeTypeText = widget.hotel.placeType == 'restaurant' ? 'ресторан' : 'отель';
    final bool isRestaurant = widget.hotel.placeType == 'restaurant';
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Аппбар с изображением
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Изображение отеля/ресторана
                  _photos.isNotEmpty
                      ? PageView.builder(
                          itemCount: _photos.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: _photos[index],
                    fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                                child: Icon(
                                  isRestaurant ? Icons.restaurant : Icons.hotel,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            isRestaurant ? Icons.restaurant : Icons.hotel,
                            size: 80,
                            color: Colors.white,
                    ),
                  ),
                  // Градиент для лучшей видимости текста
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                  // Информация внизу изображения
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        // Название и рейтинг
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                    widget.hotel.name,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 20,
                      fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                  if (widget.hotel.rating != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                      children: [
                                    const Icon(
                            Icons.star,
                            color: Colors.amber,
                                      size: 16,
                          ),
                                    const SizedBox(width: 4),
                        Text(
                                      widget.hotel.rating!.toStringAsFixed(1),
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                              ),
                          ],
                        ),
                  // Адрес
                        if (widget.hotel.vicinity != null || widget.hotel.address != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                    children: [
                                Icon(
                        Icons.location_on,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 14,
                      ),
                                const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                                    widget.hotel.vicinity ?? widget.hotel.address ?? '',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(1, 1),
                                          blurRadius: 2,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                      ),
                    ],
                  ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Кнопка добавления в избранное
              IconButton(
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                onPressed: _isProcessing ? null : _toggleFavorite,
                tooltip: 'Добавить в избранное',
              ),
              // Кнопка поделиться
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Показываем сообщение о том, что функция в разработке
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Функция "Поделиться" в разработке'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Поделиться',
              ),
            ],
          ),
          
          // Основное содержимое
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                // Быстрые действия
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _actionButton(
                            icon: Icons.map,
                            label: 'Карта',
                            onTap: _openMap,
                          ),
                          _actionButton(
                            icon: Icons.phone,
                            label: 'Позвонить',
                            onTap: _makePhoneCall,
                          ),
                          _actionButton(
                            icon: Icons.language,
                            label: 'Сайт',
                            onTap: _openWebsite,
                          ),
                          _actionButton(
                            icon: isRestaurant ? Icons.restaurant_menu : Icons.book_online,
                            label: isRestaurant ? 'Меню' : 'Номера',
                            onTap: isRestaurant 
                                ? _openWebsite 
                                : _navigateToBooking,
          ),
        ],
      ),
          ),
        ),
      ),
                
                // Информация о заведении
            Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      // Заголовок секции
                      Text(
                        'О ${isRestaurant ? 'ресторане' : 'отеле'}',
                        style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                      
                      // Описание
                      if (widget.hotel.details != null && 
                          widget.hotel.details!.containsKey('editorialSummary') && 
                          widget.hotel.details!['editorialSummary'] is Map && 
                          (widget.hotel.details!['editorialSummary'] as Map).containsKey('overview'))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            widget.hotel.details!['editorialSummary']['overview'].toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      
                      // Детали заведения в виде списка
                      _buildDetailsCard(isRestaurant),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                
                // Кнопка бронирования для отелей
                if (!isRestaurant)
            Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Забронировать номер',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Отзывы
            Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Отзывы',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                          if (widget.hotel.userRatingsTotal != null)
                            Text(
                              '${widget.hotel.userRatingsTotal} ${_getPluralForm(widget.hotel.userRatingsTotal!)}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Если есть отзывы, показываем их
                      if (widget.hotel.reviews != null && widget.hotel.reviews!.isNotEmpty)
                        ..._buildReviewsList()
                      else
                        // Иначе показываем сообщение
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Нет отзывов',
                              style: GoogleFonts.montserrat(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Добавляем пространство внизу
                const SizedBox(height: 24),
              ],
            ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
            Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(bool isRestaurant) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // Тип заведения
            if (widget.hotel.types != null && widget.hotel.types!.isNotEmpty)
              _buildDetailRow(
                icon: isRestaurant ? Icons.restaurant : Icons.hotel,
                title: 'Тип:',
                value: widget.hotel.types!.join(', '),
              ),
            
            // Телефон
            if (widget.hotel.phoneNumber != null)
              _buildDetailRow(
                icon: Icons.phone,
                title: 'Телефон:',
                value: widget.hotel.phoneNumber!,
              ),
            
            // Адрес
            if (widget.hotel.vicinity != null || widget.hotel.address != null)
              _buildDetailRow(
                icon: Icons.location_on,
                title: 'Адрес:',
                value: widget.hotel.vicinity ?? widget.hotel.address ?? '',
              ),
            
            // Часы работы
            if (widget.hotel.details != null && 
                widget.hotel.details!.containsKey('openingHours') && 
                widget.hotel.details!['openingHours'] is Map &&
                (widget.hotel.details!['openingHours'] as Map).containsKey('weekdayText') &&
                widget.hotel.details!['openingHours']['weekdayText'] is List &&
                (widget.hotel.details!['openingHours']['weekdayText'] as List).isNotEmpty)
              _buildDetailRow(
                icon: Icons.access_time,
                title: 'Часы работы:',
                value: (widget.hotel.details!['openingHours']['weekdayText'] as List).map((item) => item.toString()).join('\n'),
                isMultiline: true,
              ),
            
            // Ценовой уровень
            if (widget.hotel.priceLevel != null)
              _buildDetailRow(
                icon: Icons.attach_money,
                title: 'Ценовая категория:',
                value: '\$' * widget.hotel.priceLevel!,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                              fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildReviewsList() {
    if (widget.hotel.reviews == null || widget.hotel.reviews!.isEmpty) {
      return [];
    }
    
    return widget.hotel.reviews!.map((review) {
          return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
        ),
            child: Padding(
          padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Автор и рейтинг
                  Row(
                    children: [
                  CircleAvatar(
                    backgroundImage: review.profilePhotoUrl != null
                        ? NetworkImage(review.profilePhotoUrl!)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: review.profilePhotoUrl == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                          review.authorName ?? 'Аноним',
                          style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        if (review.relativeTimeDescription != null)
                              Text(
                            review.relativeTimeDescription!,
                            style: GoogleFonts.montserrat(
                                  fontSize: 12,
                              color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Рейтинг
                  if (review.rating != null)
                      Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                        decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        review.rating.toString(),
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  // Текст отзыва
              if (review.text != null && review.text!.isNotEmpty)
                    Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                    review.text!,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
    }).toList();
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