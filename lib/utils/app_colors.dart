import 'package:flutter/material.dart';

class AppColors {
  static bool _isDarkMode = false;

  static set isDarkMode(bool value) {
    _isDarkMode = value;
  }

  // Light Theme Colors
  static const Color primaryLight = Color(0xFF6A1B9A); // Deep Purple
  static const Color primaryVariantLight = Color(0xFF4A0072);
  static const Color secondaryLight = Color(0xFF00ACC1); // Cyan
  static const Color backgroundLight = Color(0xFFF5F5F5); // Light Grey
  static const Color surfaceLight = Colors.white;
  static const Color onPrimaryLight = Colors.white;
  static const Color onSecondaryLight = Colors.black;
  static const Color onBackgroundLight = Colors.black;
  static const Color onSurfaceLight = Colors.black;
  static const Color correctLight = Color(0xFF4CAF50); // Green
  static const Color incorrectLight = Color(0xFFF44336); // Red
  static const Color textLight = Color(0xFF757575);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFFB39DDB); // Lighter Purple
  static const Color primaryVariantDark = Color(0xFF7E57C2);
  static const Color secondaryDark = Color(0xFF80DEEA); // Lighter Cyan
  static const Color backgroundDark = Color(0xFF121212); // Very Dark Grey
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark Grey
  static const Color onPrimaryDark = Colors.black;
  static const Color onSecondaryDark = Colors.black;
  static const Color onBackgroundDark = Colors.white;
  static const Color onSurfaceDark = Colors.white;
  static const Color correctDark = Color(0xFF81C784); // Lighter Green
  static const Color incorrectDark = Color(0xFFE57373); // Lighter Red
  static const Color textDark = Color(0xFFBDBDBD);

  // Dynamic Getters
  static Color get primary => _isDarkMode ? primaryDark : primaryLight;
  static Color get primaryVariant =>
      _isDarkMode ? primaryVariantDark : primaryVariantLight;
  static Color get secondary => _isDarkMode ? secondaryDark : secondaryLight;
  static Color get background => _isDarkMode ? backgroundDark : backgroundLight;
  static Color get surface => _isDarkMode ? surfaceDark : surfaceLight;
  static Color get onPrimary => _isDarkMode ? onPrimaryDark : onPrimaryLight;
  static Color get onSecondary =>
      _isDarkMode ? onSecondaryDark : onSecondaryLight;
  static Color get onBackground =>
      _isDarkMode ? onBackgroundDark : onBackgroundLight;
  static Color get onSurface => _isDarkMode ? onSurfaceDark : onSurfaceLight;
  static Color get correct => _isDarkMode ? correctDark : correctLight;
  static Color get incorrect => _isDarkMode ? incorrectDark : incorrectLight;
  static Color get text => _isDarkMode ? textDark : textLight;
}
