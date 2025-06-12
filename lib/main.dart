import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_constants.dart';
import 'constants/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/hotel_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/admin_provider.dart';
import 'services/api_service.dart';
import 'services/favorite_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/hotels/favorites_screen.dart';
import 'screens/bookings/my_bookings_screen.dart';
import 'screens/weather_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Загрузка переменных окружения
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Файл .env успешно загружен');
    
    // Проверяем, что API ключ погоды действительно загружен
    final weatherApiKey = dotenv.env['WEATHER_API_KEY'];
    if (weatherApiKey == null || weatherApiKey.isEmpty) {
      debugPrint('API ключ погоды не найден в .env файле. Устанавливаем ключ OpenWeatherMap.');
      dotenv.env['WEATHER_API_KEY'] = 'f5cb0b965ea1364904a12bd98d0adae1';
    } else {
      debugPrint('API ключ погоды успешно загружен из .env файла: $weatherApiKey');
    }
  } catch (e) {
    debugPrint('Ошибка загрузки .env файла: $e');
    // Инициализируем dotenv вручную с заданным значением
    dotenv.testLoad(fileInput: '''
WEATHER_API_KEY=f5cb0b965ea1364904a12bd98d0adae1
API_BASE_URL=http://192.168.0.105:8000/api
''');
    debugPrint('Установлены значения по умолчанию для переменных окружения');
  }
  
  // Проверка, был ли показан вводный экран
  final prefs = await SharedPreferences.getInstance();
  final bool showIntro = !(prefs.getBool(AppConstants.introCompletedKey) ?? false);
  
  runApp(MyApp(showIntro: showIntro));
}

class MyApp extends StatelessWidget {
  final bool showIntro;
  
  const MyApp({Key? key, required this.showIntro}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create the API service first
    final apiService = ApiService();
    // Create the favorite service using the API service
    final favoriteService = FavoriteService(apiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider(favoriteService)),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: showIntro ? const IntroScreen() : const HomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin': (context) => const AdminScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/bookings': (context) => const MyBookingsScreen(),
          '/weather_test': (context) => const WeatherTestScreen(),
        },
      ),
    );
  }
}
