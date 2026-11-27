import 'package:flutter/material.dart';

class TropicaTheme {
  static const Color oceanTeal = Color(0xFF006D77);
  static const Color lagoonMint = Color(0xFF83C5BE);
  static const Color sandCream = Color(0xFFEDF6F9);
  static const Color coralAccent = Color(0xFFE29578);
  static const Color sunsetAmber = Color(0xFFFFDDD2);
  static const Color deepNavy = Color(0xFF0F293A);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: oceanTeal,
      primary: oceanTeal,
      secondary: coralAccent,
      tertiary: lagoonMint,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: sandCream,
      appBarTheme: const AppBarTheme(
        backgroundColor: oceanTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: lagoonMint.withValues(alpha: 0.35)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lagoonMint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lagoonMint.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: oceanTeal, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: oceanTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: oceanTeal.withValues(alpha: 0.16),
        backgroundColor: Colors.white,
        side: BorderSide(color: lagoonMint.withValues(alpha: 0.7)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
