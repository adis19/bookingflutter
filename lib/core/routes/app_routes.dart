import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/main/presentation/pages/main_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/search/presentation/pages/search_results_page.dart';
import '../../features/hotel/presentation/pages/hotel_detail_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/booking_confirmation_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/booking_history_page.dart';
import '../../features/profile/presentation/pages/favorites_page.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String home = '/home';
  static const String search = '/search';
  static const String searchResults = '/search-results';
  static const String hotelDetail = '/hotel-detail';
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String bookingHistory = '/booking-history';
  static const String favorites = '/favorites';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _createRoute(const SplashPage());
      
      case onboarding:
        return _createRoute(const OnboardingPage());
      
      case login:
        return _createRoute(const LoginPage());
      
      case register:
        return _createRoute(const RegisterPage());
      
      case main:
        return _createRoute(const MainPage());
      
      case home:
        return _createRoute(const HomePage());
      
      case search:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(SearchPage(initialData: args));
      
      case searchResults:
        final args = settings.arguments as Map<String, dynamic>;
        return _createRoute(SearchResultsPage(searchParams: args));
      
      case hotelDetail:
        final hotelId = settings.arguments as String;
        return _createRoute(HotelDetailPage(hotelId: hotelId));
      
      case booking:
        final args = settings.arguments as Map<String, dynamic>;
        return _createRoute(BookingPage(
          hotelId: args['hotelId'],
          roomId: args['roomId'],
        ));
      
      case bookingConfirmation:
        final bookingId = settings.arguments as String;
        return _createRoute(BookingConfirmationPage(bookingId: bookingId));
      
      case profile:
        return _createRoute(const ProfilePage());
      
      case editProfile:
        return _createRoute(const EditProfilePage());
      
      case bookingHistory:
        return _createRoute(const BookingHistoryPage());
      
      case favorites:
        return _createRoute(const FavoritesPage());
      
      default:
        return _createRoute(
          Scaffold(
            body: Center(
              child: Text('Страница не найдена: ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Helper methods for navigation
  static void pushNamed(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void pushReplacementNamed(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void pushNamedAndClearStack(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }
}
