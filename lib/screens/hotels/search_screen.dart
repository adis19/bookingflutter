import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_constants.dart';
import '../../providers/hotel_provider.dart';
import '../../widgets/hotel_card.dart';
import 'hotel_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  double _minRating = 3.0;
  int _radius = 5000;  // 5 км по умолчанию
  Position? _currentPosition;
  bool _isLocationLoading = false;
  String? _locationError;
  bool _showFilters = false; // По умолчанию скрыты
  
  // Тип заведения для поиска (отель или ресторан)
  String _placeType = 'hotel'; // По умолчанию ищем отели
  
  @override
  void initState() {
    super.initState();
    // Отложенный запрос геолокации для избежания ошибок при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition();
    });
    
    // Очищаем предыдущие результаты поиска
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HotelProvider>(context, listen: false).clearSearchResults();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  /// Determine the current position of the device.
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<void> _determinePosition() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });
    
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the 
        // App to enable the location services.
        setState(() {
          _isLocationLoading = false;
          _locationError = 'Службы геолокации отключены. Пожалуйста, включите их в настройках устройства.';
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale 
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          setState(() {
            _isLocationLoading = false;
            _locationError = 'Разрешения на местоположение отклонены. Некоторые функции будут недоступны.';
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately. 
        setState(() {
          _isLocationLoading = false;
          _locationError = 'Разрешения на местоположение отклонены навсегда. Пожалуйста, разрешите доступ в настройках приложения.';
        });
        return;
      } 

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;
      });
      
      // Получаем название города
      await _getCityName(position);
      
      // Показываем сообщение о текущем городе
      if (_cityName != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ваш текущий город: $_cityName'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Ошибка при определении местоположения: $e');
      setState(() {
        _isLocationLoading = false;
        _locationError = 'Ошибка при получении местоположения: $e';
      });
    }
  }
  
  String? _cityName;
  
  /// Получение названия города по координатам
  Future<void> _getCityName(Position position) async {
    try {
      // Получаем название города по координатам
      final placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
        localeIdentifier: 'ru_RU'
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _cityName = place.locality ?? place.administrativeArea ?? 'Неизвестный город';
          debugPrint('Определен город: $_cityName');
        });
      }
    } catch (e) {
      debugPrint('Ошибка при получении информации о городе: $e');
    }
  }
  
  Future<void> _searchHotels() async {
    // Скрываем клавиатуру
    FocusScope.of(context).unfocus();
    
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    
    // Очищаем предыдущую ошибку
    hotelProvider.clearError();
    
    String? location;
    if (_currentPosition != null) {
      location = '${_currentPosition!.latitude},${_currentPosition!.longitude}';
      debugPrint('Поиск с использованием местоположения: $location');
    } else {
      debugPrint('Поиск без использования местоположения');
    }
    
    // Проверяем, что введен хотя бы один критерий поиска
    if (_searchController.text.isEmpty && location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите название заведения/города или разрешите доступ к местоположению'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    await hotelProvider.searchHotels(
      query: _searchController.text,
      location: location,
      radius: _radius.toInt(),
      minRating: _minRating > 0 ? _minRating : null,
      placeType: _placeType, // Передаем тип заведения
    );
    
    // Показываем сообщение о результатах поиска
    if (mounted && hotelProvider.searchResults.isNotEmpty) {
      final searchText = _placeType == 'restaurant' ? 'ресторанов' : 'отелей';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Найдено ${hotelProvider.searchResults.length} $searchText'),
          duration: const Duration(seconds: 2),
        ),
      );
      // Скрываем фильтры после успешного поиска
      setState(() {
        _showFilters = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Поиск отелей',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя панель поиска
            Container(
              color: AppConstants.primaryColor,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Радио-кнопки для выбора типа места
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _placeType = 'hotel';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _placeType == 'hotel' 
                                  ? Colors.white.withOpacity(0.2) 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.hotel,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Отели',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _placeType = 'restaurant';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _placeType == 'restaurant' 
                                  ? Colors.white.withOpacity(0.2) 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Рестораны',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Поле поиска с кнопкой поиска
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Бишкек отели',
                              hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              suffixIcon: _searchController.text.isNotEmpty 
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    ) 
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            style: GoogleFonts.montserrat(),
                            onSubmitted: (_) => _searchHotels(),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Кнопка фильтров
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                          icon: Icon(
                            _showFilters ? Icons.filter_list_off : Icons.tune,
                            color: Colors.white,
                          ),
                          tooltip: _showFilters ? 'Скрыть фильтры' : 'Показать фильтры',
                        ),
                      ),
                    ],
                  ),
                  
                  // Местоположение (индикатор)
                  if (_isLocationLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Определение местоположения...',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_locationError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Местоположение не определено',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_currentPosition != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Местоположение определено',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (_cityName != null)
                            Text(
                              _cityName!,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Блок фильтров (показываем только если _showFilters = true)
            if (_showFilters)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Фильтры поиска',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _showFilters = false;
                            });
                          },
                          tooltip: 'Скрыть фильтры',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Минимальный рейтинг: ${_minRating.toStringAsFixed(1)}',
                      style: GoogleFonts.montserrat(
                        color: AppConstants.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      activeColor: AppConstants.primaryColor,
                      label: _minRating.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _minRating = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Радиус поиска: ${(_radius / 1000).toStringAsFixed(1)} км',
                      style: GoogleFonts.montserrat(
                        color: AppConstants.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _radius.toDouble(),
                      min: 1000,
                      max: 50000,
                      divisions: 49,
                      activeColor: AppConstants.primaryColor,
                      label: '${(_radius / 1000).toStringAsFixed(1)} км',
                      onChanged: (value) {
                        setState(() {
                          _radius = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            
            // Результаты поиска
            Expanded(
              child: _buildSearchResults(hotelProvider),
            ),
          ],
        ),
      ),
      // Плавающая кнопка поиска
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _searchHotels,
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.search, color: Colors.white),
        label: Text(
          'Найти ${_placeType == "hotel" ? "отели" : "рестораны"}',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildSearchResults(HotelProvider hotelProvider) {
    if (hotelProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (hotelProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка: ${hotelProvider.error}',
                style: GoogleFonts.montserrat(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _searchHotels,
                child: const Text('Попробовать снова'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (hotelProvider.searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _placeType == 'hotel' ? Icons.hotel : Icons.restaurant,
                color: Colors.grey,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Результатов не найдено',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Попробуйте изменить параметры поиска\nили проверьте интернет-соединение',
                style: GoogleFonts.montserrat(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Отступ снизу для FAB
      itemCount: hotelProvider.searchResults.length,
      itemBuilder: (context, index) {
        final hotel = hotelProvider.searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: HotelCard(
            hotel: hotel,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelDetailsScreen(hotel: hotel),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
