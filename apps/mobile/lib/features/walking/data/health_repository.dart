import 'package:health/health.dart';

class HealthRepository {
  final Health health = Health();

  Future<bool> requestPermission() async {
    final types = [
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_DELTA,
    ];

    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    return await health.requestAuthorization(
      types,
      permissions: permissions,
    );
  }

  Future<int> getTodaySteps() async {
    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final end = now;

    final steps = await health.getTotalStepsInInterval(
      start,
      end,
    );

    return steps ?? 0;
  }

  Future<double> getTodayDistanceKm() async {
    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final end = now;

    final data = await health.getHealthDataFromTypes(
      start,
      end,
      [
        HealthDataType.DISTANCE_DELTA,
      ],
    );

    double distance = 0;

    for (final item in data) {
      distance +=
          (item.value as NumericHealthValue).numericValue;
    }

    return distance / 1000;
  }
}
