import 'package:health/health.dart';

import '../services/health_service.dart';

class HealthRepository {
  HealthRepository(this._healthService);

  final HealthService _healthService;

  /// ----------------------------------------------------------
  /// 권한 요청
  /// ----------------------------------------------------------
  Future<bool> requestAuthorization() async {
    return _healthService.requestAuthorization();
  }

  /// ----------------------------------------------------------
  /// 오늘 걸음수
  /// ----------------------------------------------------------
  Future<int> getTodaySteps() async {
    try {
      final steps = await _healthService.getTodaySteps();

      if (steps < 0) {
        return 0;
      }

      return steps;
    } catch (e) {
      print("HealthRepository getTodaySteps : $e");
      return 0;
    }
  }

  /// ----------------------------------------------------------
  /// 최근 N일 걸음수
  /// ----------------------------------------------------------
  Future<List<int>> getLast7DaysSteps() async {
    final List<int> result = [];

    for (int i = 6; i >= 0; i--) {
      final value = await _healthService.getStepsByDate(
        DateTime.now().subtract(Duration(days: i)),
      );

      result.add(value);
    }

    return result;
  }

  /// ----------------------------------------------------------
  /// 이번주 총 걸음수
  /// ----------------------------------------------------------
  Future<int> getWeeklySteps() async {
    final list = await getLast7DaysSteps();

    return list.fold(
      0,
      (sum, item) => sum + item,
    );
  }

  /// ----------------------------------------------------------
  /// 이번달 총 걸음수
  /// ----------------------------------------------------------
  Future<int> getMonthlySteps() async {
    int total = 0;

    final now = DateTime.now();

    final start =
        DateTime(now.year, now.month, 1);

    final days =
        now.difference(start).inDays + 1;

    for (int i = 0; i < days; i++) {
      total += await _healthService.getStepsByDate(
        start.add(Duration(days: i)),
      );
    }

    return total;
  }

  /// ----------------------------------------------------------
  /// 칼로리(대략)
  /// ----------------------------------------------------------
  Future<double> estimateCalories() async {
    final steps = await getTodaySteps();

    return steps * 0.04;
  }

  /// ----------------------------------------------------------
  /// 거리(km)
  /// 평균 보폭 0.7m
  /// ----------------------------------------------------------
  Future<double> estimateDistanceKm() async {
    final steps = await getTodaySteps();

    return (steps * 0.7) / 1000;
  }

  /// ----------------------------------------------------------
  /// Health Connect 사용 가능 여부
  /// ----------------------------------------------------------
  Future<bool> isHealthAvailable() async {
    return _healthService.isAvailable();
  }
}
