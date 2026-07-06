import 'dart:io';

import 'package:health/health.dart';

class HealthService {
  HealthService._();

  static final HealthService instance = HealthService._();

  final Health _health = Health();

  /// 앱에서 사용할 건강 데이터 종류
  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
  ];

  /// 권한 요청
  Future<bool> requestPermission() async {
    final permissions =
        List.generate(_types.length, (_) => HealthDataAccess.READ);

    return await _health.requestAuthorization(
      _types,
      permissions: permissions,
    );
  }

  /// 오늘 걸음수
  Future<int> getTodaySteps() async {
    try {
      return await _health.getTotalStepsInInterval(
            _todayStart(),
            DateTime.now(),
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  /// 오늘 이동거리(km)
  Future<double> getTodayDistance() async {
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: _todayStart(),
        endTime: DateTime.now(),
        types: [
          HealthDataType.DISTANCE_WALKING_RUNNING,
        ],
      );

      double total = 0;

      for (final item in data) {
        total += (item.value as NumericHealthValue).numericValue.toDouble();
      }

      // meter → km
      return total / 1000;
    } catch (_) {
      return 0;
    }
  }

  DateTime _todayStart() {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
    );
  }

  bool get isAndroid => Platform.isAndroid;

  bool get isIOS => Platform.isIOS;
}
