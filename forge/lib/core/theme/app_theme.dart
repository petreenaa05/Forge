import 'package:flutter/material.dart';

class AppTheme {
  // ── Forge palette ──────────────────────────────────────────────────────────
  static const Color primary   = Color(0xFF7D938A); // sage green  — buttons, stars, accents
  static const Color secondary = Color(0xFFADA0A6); // muted mauve — card backgrounds
  static const Color tertiary  = Color(0xFFDED6D6); // rose linen  — page background, search bar

  // Derived / legacy aliases kept for backward compat
  static const Color primaryLight = Color(0xFF9DAFA8);
  static const Color accent       = Color(0xFFADA0A6); // secondary reused as accent
  static const Color background   = Color(0xFFECE8E8); // slightly lighter tertiary
  static const Color surface      = Colors.white;
  static const Color textDark     = Color(0xFF2C2C2C);
  static const Color textMedium   = Color(0xFF6B6B6B);
  static const Color verified     = Color(0xFF4CAF79);

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
        backgroundColor: surface,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
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
        backgroundColor: tertiary,
        labelStyle: const TextStyle(color: primary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
