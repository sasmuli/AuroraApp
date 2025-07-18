import 'package:flutter/material.dart';

class AuroraTheme {
  // Primary colors
  static const Color _primaryLight = Color(0xFF6B4EFF); // Purple
  static const Color _primaryDark = Color(
    0xFF9D8CFF,
  ); // Lighter purple for dark mode

  // Background colors
  static const Color _backgroundLight = Color(0xFFF8F9FA);
  static const Color _backgroundDark = Color(0xFF121212);

  // Surface colors
  static const Color _surfaceLight = Colors.white;
  static const Color _surfaceDark = Color(0xFF1E1E1E);

  // Accent colors
  static const Color _accentLight = Color(0xFF00C6AE); // Teal
  static const Color _accentDark = Color(
    0xFF4EECD6,
  ); // Brighter teal for dark mode

  // Error colors
  static const Color _errorLight = Color(0xFFE53935);
  static const Color _errorDark = Color(0xFFFF5252);

  // Text colors
  static const Color _textPrimaryLight = Color(0xFF212121);
  static const Color _textPrimaryDark = Color(0xFFEEEEEE);
  static const Color _textSecondaryLight = Color(0xFF757575);
  static const Color _textSecondaryDark = Color(0xFFBDBDBD);

  // Aurora-specific colors (for aurora borealis theme)
  static const Color auroraGreen = Color(0xFF26D07C);
  static const Color auroraBlue = Color(0xFF1A88FF);
  static const Color auroraPurple = Color(0xFF8A4EFF);
  static const Color auroraPink = Color(0xFFFF4E8A);

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        primary: _primaryLight,
        onPrimary: Colors.white,
        secondary: _accentLight,
        onSecondary: Colors.white,
        error: _errorLight,
        onError: Colors.white,
        surface: _surfaceLight,
        onSurface: _textPrimaryLight,
      ),
      scaffoldBackgroundColor: _backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceLight,
        selectedItemColor: _primaryLight,
        unselectedItemColor: _textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: _surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: _textPrimaryLight),
        displayMedium: TextStyle(color: _textPrimaryLight),
        displaySmall: TextStyle(color: _textPrimaryLight),
        headlineLarge: TextStyle(color: _textPrimaryLight),
        headlineMedium: TextStyle(color: _textPrimaryLight),
        headlineSmall: TextStyle(color: _textPrimaryLight),
        titleLarge: TextStyle(color: _textPrimaryLight),
        titleMedium: TextStyle(color: _textPrimaryLight),
        titleSmall: TextStyle(color: _textPrimaryLight),
        bodyLarge: TextStyle(color: _textPrimaryLight),
        bodyMedium: TextStyle(color: _textPrimaryLight),
        bodySmall: TextStyle(color: _textSecondaryLight),
        labelLarge: TextStyle(color: _textPrimaryLight),
        labelMedium: TextStyle(color: _textPrimaryLight),
        labelSmall: TextStyle(color: _textSecondaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.dark(
        primary: _primaryDark,
        onPrimary: Colors.black,
        secondary: _accentDark,
        onSecondary: Colors.black,
        error: _errorDark,
        onError: Colors.black,
        surface: _surfaceDark,
        onSurface: _textPrimaryDark,
      ),
      scaffoldBackgroundColor: _backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceDark,
        foregroundColor: _textPrimaryDark,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceDark,
        selectedItemColor: _primaryDark,
        unselectedItemColor: _textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
