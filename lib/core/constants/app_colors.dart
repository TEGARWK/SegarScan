import 'package:flutter/material.dart';

/// App color palette matching SegarScan UI Design System
class AppColors {
  AppColors._();

  // Brand Green Colors
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color primaryDark = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color secondaryGreen = Color(0xFF81C784);

  // Background & Surfaces
  static const Color backgroundLight = Color(0xFFF8FAF8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Fruit Quality Status Tokens
  // 🟢 Bagus (Good)
  static const Color qualityGood = Color(0xFF2E7D32);
  static const Color qualityGoodBg = Color(0xFFE8F5E9);

  // 🟡 Cukup (Fair)
  static const Color qualityFair = Color(0xFFF57F17);
  static const Color qualityFairBg = Color(0xFFFFF8E1);

  // 🔴 Busuk (Bad / Rotten)
  static const Color qualityBad = Color(0xFFC62828);
  static const Color qualityBadBg = Color(0xFFFFEBEE);

  // Neutral / Text
  static const Color textPrimary = Color(0xFF1B241C);
  static const Color textSecondary = Color(0xFF5A665B);
  static const Color textMuted = Color(0xFF8D998E);
}
