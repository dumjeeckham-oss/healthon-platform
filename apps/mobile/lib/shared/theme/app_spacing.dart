import 'package:flutter/widgets.dart';

/// ===============================================================
///
/// HealthON Design System
///
/// AppSpacing
///
/// 프로젝트 전체에서 사용하는 여백 규칙
///
/// ===============================================================

class AppSpacing {
  AppSpacing._();

  // -----------------------------------------------------------------
  // Space Scale
  // -----------------------------------------------------------------

  static const double none = 0;

  static const double xxs = 2;

  static const double xs = 4;

  static const double sm = 8;

  static const double md = 12;

  static const double lg = 16;

  static const double xl = 20;

  static const double xxl = 24;

  static const double xxxl = 32;

  static const double huge = 40;

  static const double giant = 48;

  static const double massive = 64;

  // -----------------------------------------------------------------
  // Padding Presets
  // -----------------------------------------------------------------

  static const EdgeInsets page =
      EdgeInsets.all(xl);

  static const EdgeInsets card =
      EdgeInsets.all(lg);

  static const EdgeInsets dialog =
      EdgeInsets.all(xxl);

  static const EdgeInsets listItem =
      EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  static const EdgeInsets section =
      EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );

  // -----------------------------------------------------------------
  // Horizontal
  // -----------------------------------------------------------------

  static const EdgeInsets hSm =
      EdgeInsets.symmetric(horizontal: sm);

  static const EdgeInsets hMd =
      EdgeInsets.symmetric(horizontal: md);

  static const EdgeInsets hLg =
      EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets hXl =
      EdgeInsets.symmetric(horizontal: xl);

  // -----------------------------------------------------------------
  // Vertical
  // -----------------------------------------------------------------

  static const EdgeInsets vSm =
      EdgeInsets.symmetric(vertical: sm);

  static const EdgeInsets vMd =
      EdgeInsets.symmetric(vertical: md);

  static const EdgeInsets vLg =
      EdgeInsets.symmetric(vertical: lg);

  static const EdgeInsets vXl =
      EdgeInsets.symmetric(vertical: xl);

  // -----------------------------------------------------------------
  // Only
  // -----------------------------------------------------------------

  static const EdgeInsets top =
      EdgeInsets.only(top: xl);

  static const EdgeInsets bottom =
      EdgeInsets.only(bottom: xl);

  static const EdgeInsets left =
      EdgeInsets.only(left: xl);

  static const EdgeInsets right =
      EdgeInsets.only(right: xl);

  // -----------------------------------------------------------------
  // Gap Widgets
  // -----------------------------------------------------------------

  static const SizedBox gapXs =
      SizedBox(height: xs);

  static const SizedBox gapSm =
      SizedBox(height: sm);

  static const SizedBox gapMd =
      SizedBox(height: md);

  static const SizedBox gapLg =
      SizedBox(height: lg);

  static const SizedBox gapXl =
      SizedBox(height: xl);

  static const SizedBox gapXxl =
      SizedBox(height: xxl);

  static const SizedBox gapHorizontalSm =
      SizedBox(width: sm);

  static const SizedBox gapHorizontalMd =
      SizedBox(width: md);

  static const SizedBox gapHorizontalLg =
      SizedBox(width: lg);

  static const SizedBox gapHorizontalXl =
      SizedBox(width: xl);
}
