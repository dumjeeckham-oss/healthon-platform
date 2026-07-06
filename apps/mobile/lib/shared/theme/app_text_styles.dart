import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ===============================================================
///
/// HealthON Design System
///
/// AppTextStyles
///
/// 프로젝트 전체 Typography
///
/// ===============================================================

class AppTextStyles {
  AppTextStyles._();

  // -----------------------------------------------------------------
  // Display
  // -----------------------------------------------------------------

  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // -----------------------------------------------------------------
  // Heading
  // -----------------------------------------------------------------

  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // -----------------------------------------------------------------
  // Title
  // -----------------------------------------------------------------

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // -----------------------------------------------------------------
  // Body
  // -----------------------------------------------------------------

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // -----------------------------------------------------------------
  // Label
  // -----------------------------------------------------------------

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  // -----------------------------------------------------------------
  // Button
  // -----------------------------------------------------------------

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
  );

  // -----------------------------------------------------------------
  // Caption
  // -----------------------------------------------------------------

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  // -----------------------------------------------------------------
  // Special
  // -----------------------------------------------------------------

  static const TextStyle stepCount = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.walking,
  );

  static const TextStyle score = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle level = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.secondary,
  );

  static const TextStyle rank = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.gold,
  );

  static const TextStyle aiTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.ai,
  );

  // -----------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------

  static TextStyle colored(
    Color color,
    TextStyle base,
  ) {
    return base.copyWith(color: color);
  }

  static TextStyle bold(TextStyle style) {
    return style.copyWith(
      fontWeight: FontWeight.bold,
    );
  }
}
