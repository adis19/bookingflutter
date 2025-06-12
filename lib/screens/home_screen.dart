import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather/weather.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../services/weather_service.dart';
import 'hotels/search_screen.dart';
import 'hotels/hotel_list_screen.dart';
import 'bookings/my_bookings_screen.dart';
import 'profile/profile_screen.dart';
import 'hotels/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // Геолокация и погода
  Position? _currentPosition;
  Weather? _currentWeather;
  String? _cityName;
  bool _isLoading = false;
  final WeatherService _weatherService = WeatherService();
  
  // Координаты Бишкека
  final double _bishkekLat = 42.8746;
  final double _bishkekLon = 74.5698;
  final String _bishkekName = 'Бишкек';
  
  @override
  void initState() {
    super.initState();
    // Запрашиваем разрешение на геолокацию при запуске
    _requestLocationPermission();
    
    // Сразу устанавливаем погоду Бишкека, чтобы было что показать
    _getBishkekWeather();
  }
  
  // Запрос разрешения на использование местоположения
  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Используем метод из WeatherService для получения местоположения
      final position = await _weatherService.getCurrentLocation();
      
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
        
        // Получаем информацию о местоположении и погоде
        await _getLocationInfo(position);
      } else {
        debugPrint('Не удалось получить местоположение. Использую Бишкек по умолчанию.');
        await _useDefaultLocation();
      }
    } catch (e) {
      debugPrint('Ошибка при запросе местоположения: $e. Использую Бишкек по умолчанию.');
      await _useDefaultLocation();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Получение погоды Бишкека в качестве резервного варианта
  Future<void> _getBishkekWeather() async {
    try {
      final weather = await _weatherService.getBishkekWeather();
      if (mounted) {
        setState(() {
          _currentWeather = weather;
          _cityName = _bishkekName;
          debugPrint('Установлена погода Бишкека через OpenWeatherMap API');
        });
      }
    } catch (e) {
      debugPrint('Ошибка при получении погоды Бишкека: $e');
      
      // Используем мок-данные, если API недоступен
      if (mounted) {
        setState(() {
          _currentWeather = _createMockWeather();
          _cityName = _bishkekName;
          debugPrint('Установлена заглушка погоды для Бишкека');
        });
      }
      
      // Показываем уведомление об ошибке
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось получить данные о погоде'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  // Создаем мок-данные погоды
  Weather _createMockWeather() {
    // Создаем Map с данными о погоде
    final Map<String, dynamic> weatherData = {
      'name': _bishkekName,
      'main': {
        'temp': 299.15, // 26°C в Кельвинах (273.15 + 26 = 299.15)
        'humidity': 50,
      },
      'weather': [
        {
          'id': 803, // Облачно (код между 801-804 для разной степени облачности)
          'main': 'Clouds',
          'description': 'Облачно',
          'icon': '03d'
        }
      ],
      'wind': {
        'speed': 2.0,
        'deg': 0
      },
      'dt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'sys': {
        'sunrise': DateTime.now().subtract(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000,
        'sunset': DateTime.now().add(const Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000
      },
      'clouds': {
        'all': 75 // 75% облачности
      }
    };
    
    // Используем конструктор, принимающий Map
    return Weather(weatherData);
  }
  
  // Использование местоположения по умолчанию (Бишкек)
  Future<void> _useDefaultLocation() async {
    setState(() {
      _cityName = _bishkekName;
    });
    
    await _getBishkekWeather();
  }
  
  // Получение информации о местоположении и погоде
  Future<void> _getLocationInfo(Position position) async {
    try {
      // Получаем название города по координатам через WeatherService
      final cityName = await _weatherService.getCityFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      setState(() {
        _cityName = cityName ?? _bishkekName;
      });
      
      // Получаем информацию о погоде по координатам
      try {
        // Проверяем валидность координат
        if (position.latitude != 0 && position.longitude != 0) {
          final weather = await _weatherService.getWeatherByLocation(
            position.latitude,
            position.longitude
          );
          
          if (mounted) {
            setState(() {
              _currentWeather = weather;
              debugPrint('Получена погода по координатам: ${weather.weatherDescription}');
              
              // Если город не определен по геокодингу, но определен в ответе погоды
              if ((_cityName == null || _cityName == _bishkekName) && 
                  weather.areaName != null && 
                  weather.areaName!.isNotEmpty) {
                _cityName = weather.areaName;
                debugPrint('Город определен из ответа погоды: ${weather.areaName}');
              }
            });
          }
        } else {
          throw Exception('Координаты невалидны');
        }
      } catch (e) {
        debugPrint('Ошибка при получении погоды по координатам: $e');
        // Используем мок-данные, если API недоступен
        if (mounted) {
          setState(() {
            _currentWeather = _createMockWeather();
            debugPrint('Установлена заглушка погоды для Бишкека');
          });
        }
      }
    } catch (e) {
      debugPrint('Ошибка при получении информации о местоположении: $e');
      await _useDefaultLocation();
    }
  }
  
  void _showWeatherErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _showLocationErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }
  
  // Создаем экраны только при необходимости
  Widget _getScreenAt(int index, bool isAdmin) {
    if (isAdmin) {
      // Для админа только главная страница (админ панель открывается отдельно)
      return _buildHomeContent();
    }
    
    // Для обычных пользователей
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const MyBookingsScreen();
      case 2:
        return const FavoritesScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }
  
  // Построение главного экрана с погодой и категориями
  Widget _buildHomeContent() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return RefreshIndicator(
          onRefresh: () => _requestLocationPermission(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Блок с погодой и городом
                _buildWeatherHeader(),
                
                // Строка поиска
                _buildSearchBar(),
                
                // Категории (отели, рестораны)
                _buildCategories(),
                
                // Популярные отели
                _buildPopularHotelsSection(authProvider),
                
                // Популярные рестораны
                _buildPopularRestaurantsSection(authProvider),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Блок с погодой и названием города
  Widget _buildWeatherHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Город с иконкой местоположения
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _cityName ?? _bishkekName,
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  _requestLocationPermission();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Обновление погоды...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          else if (_currentWeather != null)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildWeatherIcon(),
                    const SizedBox(width: 16),
                    Text(
                      '${_currentWeather!.temperature?.celsius?.toStringAsFixed(1) ?? "N/A"}°C',
                      style: GoogleFonts.montserrat(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currentWeather!.weatherDescription ?? 'Неизвестно',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _weatherDetailItem(
                      Icons.water_drop, 
                      '${_currentWeather!.humidity?.toInt() ?? 0}%', 
                      'Влажность'
                    ),
                    const SizedBox(width: 24),
                    _weatherDetailItem(
                      Icons.air, 
                      '${_currentWeather!.windSpeed?.toStringAsFixed(1) ?? 0} м/с', 
                      'Ветер'
                    ),
                  ],
                ),
              ],
            )
          else
            // Если погода не загрузилась, показываем заглушку погоды вместо стандартного сообщения
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Text(
                          '☁️',
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '26°C',
                      style: GoogleFonts.montserrat(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Облачно',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _weatherDetailItem(
                      Icons.water_drop, 
                      '50%', 
                      'Влажность'
                    ),
                    const SizedBox(width: 24),
                    _weatherDetailItem(
                      Icons.air, 
                      '2.0 м/с', 
                      'Ветер'
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _requestLocationPermission,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Обновить'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  // Отображение иконки погоды
  Widget _buildWeatherIcon() {
    if (_currentWeather == null || _currentWeather!.weatherIcon == null) {
      // Если нет данных о погоде, показываем эмодзи солнца
      return const Text(
        '☀️',
        style: TextStyle(
          fontSize: 50,
        ),
      );
    }
    
    // Получаем иконку из OpenWeatherMap
    final iconCode = _currentWeather!.weatherIcon;
    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          iconUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // В случае ошибки загрузки иконки, показываем эмодзи
            return Text(
              _weatherService.getWeatherIcon(_currentWeather!.weatherConditionCode!),
              style: const TextStyle(
                fontSize: 40,
              ),
            );
          },
        ),
      ),
    );
  }
  
  // Виджет для отображения деталей погоды (влажность, ветер и т.д.)
  Widget _weatherDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
  
  // Строка поиска
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 10),
              Text(
                'Поиск отелей и ресторанов',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Категории (отели, рестораны)
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Категории',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _categoryCard(
                  icon: Icons.hotel,
                  title: 'Отели',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelListScreen(
                          placeType: 'hotel', 
                          cityName: _cityName ?? 'Бишкек',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _categoryCard(
                  icon: Icons.restaurant,
                  title: 'Рестораны',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelListScreen(
                          placeType: 'restaurant',
                          cityName: _cityName ?? 'Бишкек',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _categoryCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Секция популярных отелей
  Widget _buildPopularHotelsSection(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Популярные отели',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HotelListScreen(
                        placeType: 'hotel',
                        cityName: _cityName,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Все отели',
                  style: GoogleFonts.montserrat(
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const HotelListPreview(placeType: 'hotel'),
        ],
      ),
    );
  }
  
  // Секция популярных ресторанов
  Widget _buildPopularRestaurantsSection(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Популярные рестораны',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HotelListScreen(
                        placeType: 'restaurant',
                        cityName: _cityName,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Все рестораны',
                  style: GoogleFonts.montserrat(
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const HotelListPreview(placeType: 'restaurant'),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Используем Consumer вместо Provider.of для безопасного доступа к провайдеру
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: _getScreenAt(_selectedIndex, authProvider.isAdmin),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (authProvider.isAdmin) {
                // Для админа: 0 - главная, 1 - админ панель
                if (index == 1) {
                  Navigator.pushNamed(context, '/admin');
                } else {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              } else {
                // Для обычных пользователей
                if (!authProvider.isAuthenticated && (index == 1 || index == 2 || index == 3)) {
                  _showAuthRequiredDialog(context);
                } else {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppConstants.primaryColor,
            unselectedItemColor: AppConstants.secondaryTextColor,
            items: authProvider.isAdmin 
                ? const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Главная',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.admin_panel_settings),
                      label: 'Админ панель',
                    ),
                  ]
                : const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Главная',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.book_online),
                      label: 'Брони',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: 'Избранное',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Профиль',
                    ),
                  ],
          ),
        );
      },
    );
  }
  
  void _showAuthRequiredDialog(BuildContext context) {
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
                  Icons.login_rounded,
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
                'Для доступа к этому разделу необходимо войти в систему или зарегистрироваться.',
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
                        Navigator.pushNamed(context, '/login');
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

  // Виджет для отображения информации о погоде
  Widget _buildWeatherWidget() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (_currentWeather == null) {
      return const Text('Нет данных о погоде');
    }
    
    // Получаем данные о погоде
    final tempC = _currentWeather!.temperature?.celsius?.toStringAsFixed(1) ?? 'N/A';
    final iconCode = _currentWeather!.weatherConditionCode ?? 0;
    final description = _currentWeather!.weatherDescription ?? 'Неизвестно';
    final cityText = _cityName ?? 'Неизвестное местоположение';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                cityText,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Кнопка для тестирования API погоды
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/weather_test');
                },
                child: const Icon(
                  Icons.cloud_outlined,
                  size: 16,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor.withOpacity(0.7),
                    AppConstants.primaryColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$tempC°C',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                _weatherService.getWeatherIcon(iconCode),
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                description,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: AppConstants.textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 