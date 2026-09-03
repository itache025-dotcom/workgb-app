import 'package:flutter/material.dart';
import 'cores_novo.dart';

class TemaNovo {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: CoresNovo.navyPrimary,
      scaffoldBackgroundColor: CoresNovo.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CoresNovo.navyPrimary,
        primary: CoresNovo.navyPrimary,
        onPrimary: Colors.white,
        secondary: CoresNovo.blueSecondary,
        onSecondary: Colors.white,
        surface: CoresNovo.surface,
        onSurface: CoresNovo.textPrimary,
        background: CoresNovo.background,
        onBackground: CoresNovo.textPrimary,
        error: CoresNovo.error,
        onError: Colors.white,
        outline: CoresNovo.border,
      ),
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: CoresNovo.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: CoresNovo.navyPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: CoresNovo.navyPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: CoresNovo.navyPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: CoresNovo.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: CoresNovo.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: CoresNovo.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: CoresNovo.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CoresNovo.navyPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CoresNovo.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CoresNovo.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CoresNovo.navyPrimary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: CoresNovo.textSecondary, fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Implementação básica do modo dark seguindo as cores do design
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF8DB4E2),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8DB4E2),
        onPrimary: CoresNovo.navyPrimary,
        secondary: Color(0xFF93C5FD),
        onSecondary: Color(0xFF0F172A),
        background: Color(0xFF0F172A),
        onBackground: Color(0xFFF8FAFC),
        surface: Color(0xFF1E293B),
        onSurface: Color(0xFFF8FAFC),
        outline: Color(0xFF475569),
      ),
      fontFamily: 'Poppins',
    );
  }
}
