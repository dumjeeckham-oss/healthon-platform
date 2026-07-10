import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  /// Health Connect / Apple Health 사용 가능 여부
  Future<bool> isAvailable() async {
    return await _health.isHealthConnectAvailable();
  }

  /// 권한 요청
  Future<bool> requestAuthorization() async {
    final types = [
      HealthDataType.STEPS,
    ];

    final permissions = [
      HealthDataAccess.READ,
    ];

    return await _health.requestAuthorization(
      types,
      permissions: permissions,
    );
  }

  /// 오늘 걸음수
  Future<int> getTodaySteps() async {
    try {
      final now = DateTime.now();

      final start = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final end = now;

      final steps = await _health.getTotalStepsInInterval(
        start,
        end,
      );

      return steps ?? 0;
    } catch (e) {
      print("HealthService.getTodaySteps : $e");
      return 0;
    }
  }

  /// 특정 날짜 걸음수
  Future<int> getStepsByDate(DateTime date) async {
    try {
      final start = DateTime(
        date.year,
        date.month,
        date.day,
      );

      final end = start.add(
        const Duration(days: 1),
      );

      final steps = await _health.getTotalStepsInInterval(
        start,
        end,
      );

      return steps ?? 0;
    } catch (e) {
      print("HealthService.getStepsByDate : $e");
      return 0;
    }
  }
}
