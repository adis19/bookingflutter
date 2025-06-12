import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppConstants.backgroundColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AppConstants.backgroundColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppConstants.primaryColor),
      titleTextStyle: GoogleFonts.poppins(
        color: AppConstants.textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: AppConstants.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(AppConstants.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
        side: const BorderSide(color: AppConstants.primaryColor),
        minimumSize: const Size.fromHeight(AppConstants.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        borderSide: const BorderSide(color: AppConstants.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        borderSide: const BorderSide(color: AppConstants.errorColor),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700),
      hintStyle: TextStyle(color: Colors.grey.shade400),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: AppConstants.textColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: AppConstants.textColor,
      ),
      displaySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: AppConstants.textColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppConstants.textColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppConstants.textColor,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppConstants.textColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: AppConstants.textColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: AppConstants.textColor,
      ),
    ),
  );
} 