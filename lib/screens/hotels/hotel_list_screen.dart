import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_constants.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/hotel_card.dart';
import 'hotel_details_screen.dart';

class HotelListScreen extends StatefulWidget {
  final String placeType;
  final String? cityName;
  
  const HotelListScreen({
    Key? key,
    required this.placeType,
    this.cityName,
  }) : super(key: key);

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    if (widget.cityName != null && widget.cityName!.isNotEmpty) {
      _searchController.text = widget.cityName!;
    }
    
    Future.microtask(() => _loadPlaces());
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPlaces() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      
      if (widget.cityName != null && widget.cityName!.isNotEmpty) {
        await hotelProvider.searchHotels(
          query: widget.cityName,
          placeType: widget.placeType,
          minRating: 3.5,
        );
      } else {
        await hotelProvider.searchHotels(
          placeType: widget.placeType,
          minRating: 3.5,
        );
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке мест: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке данных: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _searchPlaces() async {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите запрос для поиска'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      await hotelProvider.searchHotels(
        query: _searchController.text,
        placeType: widget.placeType,
      );
    } catch (e) {
      debugPrint('Ошибка при поиске: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final String title = widget.placeType == 'restaurant' ? 'Рестораны' : 'Отели';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppConstants.primaryColor,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск ${widget.placeType == 'restaurant' ? 'ресторанов' : 'отелей'}',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchPlaces,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onSubmitted: (_) => _searchPlaces(),
              ),
            ),
          ),
          
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPlaces,
              child: Consumer<HotelProvider>(
                builder: (context, hotelProvider, child) {
                  if (_isLoading) {
                    return _buildLoadingList();
                  }
                  
                  if (hotelProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ошибка: ${hotelProvider.error}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadPlaces,
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final places = hotelProvider.searchResults.where(
                    (hotel) => widget.placeType == 'restaurant' ? 
                    hotel.placeTypeStr == 'restaurant' || hotel.isRestaurant :
                    hotel.placeTypeStr == 'hotel' || hotel.isHotel
                  ).toList();
                  
                  if (places.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.placeType == 'restaurant' 
                                ? Icons.restaurant_outlined 
                                : Icons.hotel_outlined,
                            color: Colors.grey,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ничего не найдено',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Попробуйте изменить параметры поиска',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: HotelCard(
                          hotel: place,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HotelDetailsScreen(hotel: place),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HotelListPreview extends StatefulWidget {
  final String placeType;
  
  const HotelListPreview({
    Key? key,
    required this.placeType,
  }) : super(key: key);
  
  @override
  State<HotelListPreview> createState() => _HotelListPreviewState();
}

class _HotelListPreviewState extends State<HotelListPreview> {
  bool _isLoading = true;
  List<dynamic> _places = [];
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadBishkekPlaces());
  }
  
  Future<void> _loadBishkekPlaces() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      
      // Очищаем предыдущие результаты
      hotelProvider.clearSearchResults();
      
      // Загружаем данные для Бишкека
      await hotelProvider.searchHotels(
        query: 'Бишкек',
        placeType: widget.placeType,
        minRating: 3.5,
        radius: 10000, // 10 км радиус
      );
      
      // Берем первые 5 результатов
      final results = hotelProvider.searchResults
          .where((hotel) => widget.placeType == 'restaurant' ? 
              (hotel.placeTypeStr == 'restaurant' || hotel.isRestaurant) :
              (hotel.placeTypeStr == 'hotel' || hotel.isHotel))
          .take(5)
          .toList();
      
      setState(() {
        _places = results;
      });
      
    } catch (e) {
      debugPrint('Ошибка при загрузке мест Бишкека: $e');
      // В случае ошибки показываем заглушки
      setState(() {
        _places = _generateMockData();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  List<dynamic> _generateMockData() {
    if (widget.placeType == 'hotel') {
      return [
        {
          'id': 1,
          'name': 'Отель Бишкек',
          'rating': 4.2,
          'vicinity': 'Центр города',
          'photos': ['https://via.placeholder.com/300x150?text=Отель+Бишкек'],
          'placeType': 'hotel'
        },
        {
          'id': 2,
          'name': 'Гостиница Достук',
          'rating': 4.0,
          'vicinity': 'ул. Фрунзе',
          'photos': ['https://via.placeholder.com/300x150?text=Достук'],
          'placeType': 'hotel'
        },
        {
          'id': 3,
          'name': 'Asia Mountains',
          'rating': 4.5,
          'vicinity': 'пр. Чуй',
          'photos': ['https://via.placeholder.com/300x150?text=Asia+Mountains'],
          'placeType': 'hotel'
        },
        {
          'id': 4,
          'name': 'Golden Dragon',
          'rating': 4.1,
          'vicinity': 'Центр Бишкека',
          'photos': ['https://via.placeholder.com/300x150?text=Golden+Dragon'],
          'placeType': 'hotel'
        },
        {
          'id': 5,
          'name': 'Plaza Hotel',
          'rating': 4.3,
          'vicinity': 'ул. Киевская',
          'photos': ['https://via.placeholder.com/300x150?text=Plaza+Hotel'],
          'placeType': 'hotel'
        },
      ];
    } else {
      return [
        {
          'id': 11,
          'name': 'Ресторан Фурчет',
          'rating': 4.4,
          'vicinity': 'пр. Чуй',
          'photos': ['https://via.placeholder.com/300x150?text=Фурчет'],
          'placeType': 'restaurant'
        },
        {
          'id': 12,
          'name': 'Navat',
          'rating': 4.6,
          'vicinity': 'ул. Токтогула',
          'photos': ['https://via.placeholder.com/300x150?text=Navat'],
          'placeType': 'restaurant'
        },
        {
          'id': 13,
          'name': 'Sierra Coffee',
          'rating': 4.3,
          'vicinity': 'Центр города',
          'photos': ['https://via.placeholder.com/300x150?text=Sierra+Coffee'],
          'placeType': 'restaurant'
        },
        {
          'id': 14,
          'name': 'Chicken Star',
          'rating': 4.1,
          'vicinity': 'ул. Манаса',
          'photos': ['https://via.placeholder.com/300x150?text=Chicken+Star'],
          'placeType': 'restaurant'
        },
        {
          'id': 15,
          'name': 'Дастархан',
          'rating': 4.5,
          'vicinity': 'пр. Мира',
          'photos': ['https://via.placeholder.com/300x150?text=Дастархан'],
          'placeType': 'restaurant'
        },
      ];
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 220,
        child: _buildLoadingPreview(),
      );
    }
    
    if (_places.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.placeType == 'restaurant' ? Icons.restaurant : Icons.hotel,
                color: Colors.grey,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Нет данных для отображения',
                style: GoogleFonts.montserrat(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _loadBishkekPlaces,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Обновить'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 4),
        itemCount: _places.length,
        itemBuilder: (context, index) {
          final place = _places[index];
          return _buildPlaceCard(place);
        },
      ),
    );
  }
  
  Widget _buildPlaceCard(dynamic place) {
    // Определяем, является ли place объектом Hotel или Map
    String name = '';
    double? rating;
    String? vicinity;
    List<String>? photos;
    
    if (place is Map) {
      // Это заглушка данных
      name = place['name'] ?? '';
      rating = place['rating']?.toDouble();
      vicinity = place['vicinity'];
      photos = place['photos']?.cast<String>();
    } else {
      // Это объект Hotel
      name = place.name ?? '';
      rating = place.rating;
      vicinity = place.vicinity ?? place.address;
      photos = place.photos;
    }
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          if (place is! Map) {
            // Переходим к деталям только для реальных объектов Hotel
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelDetailsScreen(hotel: place),
              ),
            );
          } else {
            // Для заглушек показываем сообщение
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Данные загружаются...'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Изображение с наложенным рейтингом
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Изображение
                      photos != null && photos.isNotEmpty
                          ? Image.network(
                              photos.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppConstants.primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    widget.placeType == 'restaurant' 
                                        ? Icons.restaurant 
                                        : Icons.hotel,
                                    size: 40,
                                    color: AppConstants.primaryColor,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              child: Icon(
                                widget.placeType == 'restaurant' 
                                    ? Icons.restaurant 
                                    : Icons.hotel,
                                size: 40,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                      
                      // Градиент для лучшей видимости рейтинга
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      
                      // Рейтинг
                      if (rating != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Информация о заведении
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Название
                        Text(
                          name,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppConstants.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Адрес с иконкой
                        if (vicinity != null && vicinity.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vicinity,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        
                        const SizedBox(height: 8),
                        
                        // Бейджик типа заведения
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.placeType == 'restaurant' 
                                  ? Colors.orange.withOpacity(0.15)
                                  : AppConstants.primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.placeType == 'restaurant' 
                                      ? Icons.restaurant
                                      : Icons.hotel,
                                  size: 12,
                                  color: widget.placeType == 'restaurant' 
                                      ? Colors.orange[700]
                                      : AppConstants.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.placeType == 'restaurant' ? 'Ресторан' : 'Отель',
                                  style: GoogleFonts.montserrat(
                                    color: widget.placeType == 'restaurant' 
                                        ? Colors.orange[700]
                                        : AppConstants.primaryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingPreview() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: 250,
          margin: const EdgeInsets.only(right: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}
 