import 'package:flutter/material.dart';

/// ===============================================================
///
/// HealthON Design System
///
/// AppShadows
///
/// 프로젝트 전체에서 사용하는 그림자(Elevation) 규칙
///
/// ===============================================================

class AppShadows {
  AppShadows._();

  // -----------------------------------------------------------------
  // Light
  // -----------------------------------------------------------------

  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // -----------------------------------------------------------------
  // Component Presets
  // -----------------------------------------------------------------

  static const List<BoxShadow> card = sm;

  static const List<BoxShadow> elevatedCard = md;

  static const List<BoxShadow> dialog = lg;

  static const List<BoxShadow> bottomSheet = xl;

  static const List<BoxShadow> floatingButton = lg;

  static const List<BoxShadow> appBar = xs;

  // -----------------------------------------------------------------
  // Colored Shadows
  // -----------------------------------------------------------------

  static List<BoxShadow> primary(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.25),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> success(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.20),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> warning(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.20),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> error(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.20),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ];
  }

  // -----------------------------------------------------------------
  // Helper
  // -----------------------------------------------------------------

  static List<BoxShadow> custom({
    required Color color,
    double opacity = 0.15,
    double blur = 12,
    Offset offset = const Offset(0, 6),
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blur,
        offset: offset,
      ),
    ];
  }
}
