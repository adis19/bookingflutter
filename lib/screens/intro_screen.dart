import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import 'home_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor.withOpacity(0.1),
              Colors.white,
              AppConstants.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: "Добро пожаловать в LastBooking! ✨",
              body: "Ваш надежный помощник для поиска и бронирования отелей по всему миру",
              image: _buildAnimationContainer(
                context, 
                'onboarding_1.json',
                Icons.hotel_rounded,
                [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              decoration: _getPageDecoration(),
            ),
            PageViewModel(
              title: "Умный поиск отелей 🔍",
              body: "Находите лучшие отели с помощью Google Places API. Просматривайте фотографии, отзывы и всю необходимую информацию",
              image: _buildAnimationContainer(
                context, 
                'onboarding_2.json',
                Icons.search_rounded,
                [Color(0xFF11998e), Color(0xFF38ef7d)],
              ),
              decoration: _getPageDecoration(),
            ),
            PageViewModel(
              title: "Быстрое бронирование ⚡",
              body: "Бронируйте номера в отелях всего в несколько кликов. Управляйте своими бронированиями в личном кабинете",
              image: _buildAnimationContainer(
                context, 
                'onboarding_3.json',
                Icons.calendar_today_rounded,
                [Color(0xFFfc4a1a), Color(0xFFf7b733)],
              ),
              decoration: _getPageDecoration(),
            ),
            PageViewModel(
              title: "Персональные избранные ❤️",
              body: "Сохраняйте понравившиеся отели в избранное, чтобы не потерять их из виду и быстро найти снова",
              image: _buildAnimationContainer(
                context, 
                'onboarding_4.json',
                Icons.favorite_rounded,
                [Color(0xFF8360c3), Color(0xFF2ebf91)],
              ),
              decoration: _getPageDecoration(),
            ),
          ],
          showSkipButton: true,
          skip: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.double_arrow_rounded,
              color: AppConstants.primaryColor,
              size: 18,
            ),
          ),
          next: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          done: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          dotsDecorator: DotsDecorator(
            size: const Size(10.0, 10.0),
            color: Colors.grey.withOpacity(0.5),
            activeSize: const Size(22.0, 10.0),
            activeColor: AppConstants.primaryColor,
            activeShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
            spacing: const EdgeInsets.symmetric(horizontal: 4),
          ),
          globalFooter: Container(
            height: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationContainer(BuildContext context, String animationFile, IconData fallbackIcon, List<Color> gradient) {
    return Container(
      height: 260,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient[0].withOpacity(0.18),
            gradient[1].withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Фоновые декоративные элементы
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gradient[0].withOpacity(0.2),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -30,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gradient[1].withOpacity(0.2),
                ),
              ),
            ),
            // Основной градиентный фон
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            // Lottie анимация или fallback иконка
            Center(
              child: _buildAnimationWidget(context, animationFile, fallbackIcon, gradient),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationWidget(BuildContext context, String animationFile, IconData fallbackIcon, List<Color> gradient) {
    return FutureBuilder<bool>(
      future: _checkAnimationExists(context, animationFile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Показываем fallback пока проверяем файл
          return _buildFallbackIcon(fallbackIcon, gradient);
        }
        
        if (snapshot.hasData && snapshot.data == true) {
          // Файл существует, показываем Lottie анимацию
          return Lottie.asset(
            'assets/animations/$animationFile',
            height: 200,
            width: 200,
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            errorBuilder: (context, error, stackTrace) {
              // Если ошибка в Lottie, показываем fallback
              return _buildFallbackIcon(fallbackIcon, gradient);
            },
          );
        } else {
          // Файл не существует, показываем fallback иконку
          return _buildFallbackIcon(fallbackIcon, gradient);
        }
      },
    );
  }

  Widget _buildFallbackIcon(IconData icon, List<Color> gradient) {
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Эффект блика
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          // Основная иконка
          Icon(
            icon,
            size: 55,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Future<bool> _checkAnimationExists(BuildContext context, String fileName) async {
    try {
      await DefaultAssetBundle.of(context).load('assets/animations/$fileName');
      return true;
    } catch (e) {
      return false;
    }
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
        color: AppConstants.textColor,
        letterSpacing: 0.5,
      ),
      bodyTextStyle: GoogleFonts.montserrat(
        fontSize: 16.0,
        color: AppConstants.secondaryTextColor,
        height: 1.6,
        letterSpacing: 0.2,
      ),
      pageColor: Colors.transparent,
      imagePadding: const EdgeInsets.only(top: 50, bottom: 30),
      contentMargin: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.only(top: 24, bottom: 16),
      bodyPadding: const EdgeInsets.only(bottom: 40),
    );
  }

  void _onIntroEnd(BuildContext context) async {
    // Показываем красивую анимацию загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                        strokeWidth: 3,
                      ),
                    ),
                    Icon(
                      Icons.flight_takeoff_rounded,
                      color: AppConstants.primaryColor,
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Загрузка...',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Сохраняем информацию о том, что вводный экран был показан
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.introCompletedKey, true);
    
    // Небольшая задержка для эффекта
    await Future.delayed(const Duration(seconds: 1));
    
    // Переходим на главный экран
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }
}
