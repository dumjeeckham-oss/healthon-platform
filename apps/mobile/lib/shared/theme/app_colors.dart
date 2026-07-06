import 'package:flutter/material.dart';

/// ===============================================================
///
/// HealthON Design System
///
/// App Colors
///
/// 프로젝트 전체에서 사용하는 색상 정의
///
/// ===============================================================

class AppColors {
  AppColors._();

  // -----------------------------------------------------------------
  // Brand
  // -----------------------------------------------------------------

  static const Color primary = Color(0xFF2563EB);

  static const Color secondary = Color(0xFF10B981);

  static const Color tertiary = Color(0xFFF59E0B);

  // -----------------------------------------------------------------
  // Background
  // -----------------------------------------------------------------

  static const Color background = Color(0xFFF8FAFC);

  static const Color surface = Colors.white;

  static const Color card = Colors.white;

  // -----------------------------------------------------------------
  // Text
  // -----------------------------------------------------------------

  static const Color textPrimary = Color(0xFF111827);

  static const Color textSecondary = Color(0xFF6B7280);

  static const Color textHint = Color(0xFF9CA3AF);

  static const Color textOnPrimary = Colors.white;

  // -----------------------------------------------------------------
  // Border
  // -----------------------------------------------------------------

  static const Color border = Color(0xFFE5E7EB);

  static const Color divider = Color(0xFFF1F5F9);

  // -----------------------------------------------------------------
  // Status
  // -----------------------------------------------------------------

  static const Color success = Color(0xFF22C55E);

  static const Color warning = Color(0xFFF59E0B);

  static const Color error = Color(0xFFEF4444);

  static const Color info = Color(0xFF3B82F6);

  // -----------------------------------------------------------------
  // Rank
  // -----------------------------------------------------------------

  static const Color gold = Color(0xFFFFC107);

  static const Color silver = Color(0xFFB0BEC5);

  static const Color bronze = Color(0xFFB87333);

  // -----------------------------------------------------------------
  // Health
  // -----------------------------------------------------------------

  static const Color heart = Color(0xFFE53935);

  static const Color walking = Color(0xFF43A047);

  static const Color ai = Color(0xFF7C3AED);

  static const Color family = Color(0xFF0EA5E9);

  // -----------------------------------------------------------------
  // Progress
  // -----------------------------------------------------------------

  static const Color progressBackground =
      Color(0xFFE2E8F0);

  static const Color progressValue =
      primary;

  // -----------------------------------------------------------------
  // Chip
  // -----------------------------------------------------------------

  static const Color chipBackground =
      Color(0xFFF3F4F6);

  // -----------------------------------------------------------------
  // Medal
  // -----------------------------------------------------------------

  static const Color medalGold =
      Color(0xFFFFD54F);

  static const Color medalSilver =
      Color(0xFFCFD8DC);

  static const Color medalBronze =
      Color(0xFFD7A86E);

  // -----------------------------------------------------------------
  // Online
  // -----------------------------------------------------------------

  static const Color online =
      Color(0xFF22C55E);

  static const Color offline =
      Color(0xFF94A3B8);

  // -----------------------------------------------------------------
  // Challenge
  // -----------------------------------------------------------------

  static const Color challenge =
      Color(0xFFFB923C);

  // -----------------------------------------------------------------
  // Disabled
  // -----------------------------------------------------------------

  static const Color disabled =
      Color(0xFFCBD5E1);

  // -----------------------------------------------------------------
  // Overlay
  // -----------------------------------------------------------------

  static const Color overlay =
      Color(0x66000000);

  // -----------------------------------------------------------------
  // Gradient
  // -----------------------------------------------------------------

  static const LinearGradient primaryGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF3B82F6),
    ],
  );

  static const LinearGradient healthGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF34D399),
    ],
  );

  static const LinearGradient aiGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED),
      Color(0xFFA855F7),
    ],
  );

  static const LinearGradient goldGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD54F),
      Color(0xFFFFB300),
    ],
  );
}
