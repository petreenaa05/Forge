import 'package:flutter/material.dart';

class AppTheme {
  // ── Forge palette — Maroon brand─────────────────────────────────────────
  static const Color primary      = Color(0xFFA82323); // maroon — brand primary
  static const Color primaryDark  = Color(0xFF7A1818); // pressed state
  static const Color primaryLight = Color(0xFFFDF2F2); // subtle tinted bg
  static const Color secondary    = Color(0xFF1A1A1A); // dark secondary
  static const Color tertiary     = Color(0xFFF7F7F7); // light neutral bg

  // Derived / legacy aliases kept for backward compat
  static const Color accent       = Color(0xFFA82323); // maroon accent
  static const Color background   = Color(0xFFF9F9F9); // page background
  static const Color surface      = Colors.white;
  static const Color textDark     = Color(0xFF1A1A1A);
  static const Color textMedium   = Color(0xFF6B6B6B);
  static const Color verified     = Color(0xFF2E7D32);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryLight,
        labelStyle: const TextStyle(color: primary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
