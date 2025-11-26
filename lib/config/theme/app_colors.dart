import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFFFDEFEF); // Soft pink/beige
  static const Color accent = Color(0xFFE46360); // Coral red

  // Background colors
  static const Color backgroundLight = Color(0xFFEEEEEE); // Light grey
  static const Color backgroundDark = Color(0xFF404040); // Dark grey
  static const Color backgroundDarker = Color(0xFF333333); // Darker grey

  // Surface colors
  static const Color surfaceLight = Color(0xFFFDFDFD); // Almost white
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Pure white

  // Accent variations
  static const Color accentDark = Color(0xFF806360); // Dark coral
  static const Color accentMedium = Color(0xFFA86360); // Medium coral

  // Text colors (derived from palette)
  static const Color textDark = backgroundDarker;
  static const Color textMedium = backgroundDark;
  static const Color textLight = backgroundLight;
  static const Color textOnAccent = surfaceWhite;

  // Status colors (using accent as base)
  static const Color success = Color(0xFF60A886); // Green derived from palette
  static const Color warning = Color(0xFFA88660); // Orange derived from palette
  static const Color error = accent;
  static const Color info = accentMedium;
}
