import 'package:flutter/material.dart';

/// ===============================================================
///
/// HealthON Design System
///
/// AppRadius
///
/// 앱 전체에서 사용하는 Radius 규칙
///
/// ===============================================================

class AppRadius {
  AppRadius._();

  // -----------------------------------------------------------------
  // Radius Values
  // -----------------------------------------------------------------

  static const double none = 0;

  static const double xs = 4;

  static const double sm = 8;

  static const double md = 12;

  static const double lg = 16;

  static const double xl = 20;

  static const double xxl = 24;

  static const double round = 999;

  // -----------------------------------------------------------------
  // BorderRadius
  // -----------------------------------------------------------------

  static const BorderRadius xsRadius =
      BorderRadius.all(
    Radius.circular(xs),
  );

  static const BorderRadius smRadius =
      BorderRadius.all(
    Radius.circular(sm),
  );

  static const BorderRadius mdRadius =
      BorderRadius.all(
    Radius.circular(md),
  );

  static const BorderRadius lgRadius =
      BorderRadius.all(
    Radius.circular(lg),
  );

  static const BorderRadius xlRadius =
      BorderRadius.all(
    Radius.circular(xl),
  );

  static const BorderRadius xxlRadius =
      BorderRadius.all(
    Radius.circular(xxl),
  );

  static const BorderRadius pill =
      BorderRadius.all(
    Radius.circular(round),
  );

  // -----------------------------------------------------------------
  // Common Shapes
  // -----------------------------------------------------------------

  static const RoundedRectangleBorder cardShape =
    RoundedRectangleBorder(
    borderRadius: xlRadius,
  );

  static const RoundedRectangleBorder dialogShape =
    RoundedRectangleBorder(
    borderRadius: xxlRadius,
  );

  static const RoundedRectangleBorder buttonShape =
    RoundedRectangleBorder(
    borderRadius: lgRadius,
  );

  static const RoundedRectangleBorder chipShape =
    RoundedRectangleBorder(
    borderRadius: pill,
  );

  // -----------------------------------------------------------------
  // Helper
  // -----------------------------------------------------------------

  static BorderRadius circular(
    double value,
  ) {
    return BorderRadius.circular(value);
  }
}
