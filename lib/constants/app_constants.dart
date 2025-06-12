import 'package:flutter/material.dart';

class AppConstants {
  // Цвета
  static const Color primaryColor = Color(0xFF1A73E8);
  static const Color accentColor = Color(0xFF4285F4);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF202124);
  static const Color secondaryTextColor = Color(0xFF5F6368);
  static const Color errorColor = Color(0xFFD93025);
  static const Color successColor = Color(0xFF34A853);
  
  // Размеры
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double buttonHeight = 56.0;
  
  // Анимации
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Тексты
  static const String appName = 'LastBooking';
  
  // Ключи для хранения данных
  static const String introCompletedKey = 'intro_completed';
  
  // Ключи API
  static const String googleApiKey = 'AIzaSyD7vOGtJpBivX2YTbZC63lBi5XDYmbfM8o';
} 