import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0066FF);      // Blue
  static const Color secondary = Color(0xFFFFA726);    // Orange
  static const Color background = Color(0xFFF6F6F6);   // Light background
  static const Color textPrimary = Color(0xFF333333);  // Dark text
  static const Color danger = Color(0xFFE53935);       // Red
  static const Color success = Color(0xFF43A047);      // Green
  static const Color lightGrey = Color(0xFFE0E0E0);    // Light grey
  static const Color black54 = Colors.black54;
  static const Color white = Colors.white;
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      surface: AppColors.white,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.black54,
        fontSize: 14,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.primary),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.white,
    ),
    cardColor: AppColors.white,
  );
}
