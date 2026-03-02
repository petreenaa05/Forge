import 'package:flutter/material.dart';

/// Forge Chat Design System
///
/// Palette:
///   Primary   → #7D938A  Sage green (calm, trustworthy)
///   Secondary → #ADA0A6  Dusty mauve (warm, feminine)
///   Tertiary  → #DED6D6  Warm gray (soft surfaces)
class ChatTheme {
  static const Color primary = Color(0xFF7D938A);
  static const Color primaryDark = Color(0xFF5E7268);
  static const Color primaryLight = Color(0xFFB5C4BC);
  static const Color primarySurface = Color(0xFFEDF1EF);

  static const Color secondary = Color(0xFFADA0A6);
  static const Color secondaryDark = Color(0xFF8A7D83);
  static const Color secondaryLight = Color(0xFFCDC5C9);
  static const Color secondarySurface = Color(0xFFF3F0F1);

  static const Color tertiary = Color(0xFFDED6D6);
  static const Color tertiaryLight = Color(0xFFF0ECEC);
  static const Color tertiarySurface = Color(0xFFF8F6F6);

  static const Color background = Color(0xFFFAF8F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFDFCFC);

  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textMuted = Color(0xFF9BA3A7);
  static const Color textOnPrimary = Color(0xFFFFFEFE);

  static const Color success = Color(0xFF7D938A);
  static const Color warning = Color(0xFFD4A574);
  static const Color error = Color(0xFFC17B7B);
  static const Color info = Color(0xFF8BA4B0);

  static const Color myBubble = Color(0xFF7D938A);
  static const Color theirBubble = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF3F0F1);
  static const Color onlineDot = Color(0xFF7D938A);
  static const Color unreadBadge = Color(0xFF7D938A);
  static const Color typingDot = Color(0xFFADA0A6);
  static const Color readTick = Color(0xFF8BA4B0);

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration entrance = Duration(milliseconds: 600);
  static const Duration stagger = Duration(milliseconds: 45);

  static const Curve curveSmooth = Curves.easeOutCubic;
  static const Curve curveSpring = Curves.easeOutBack;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSharp = Curves.easeOutQuart;
  static const Curve curveDecel = Curves.decelerate;
}
