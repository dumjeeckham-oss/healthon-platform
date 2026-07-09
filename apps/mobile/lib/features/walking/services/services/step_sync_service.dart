import 'package:flutter/foundation.dart';

import '../../data/health_repository.dart';
import '../../data/step_repository_impl.dart';

class StepSyncService {
  StepSyncService({
    required HealthRepository healthRepository,
    required StepRepositoryImpl stepRepository,
  })  : _healthRepository = healthRepository,
        _stepRepository = stepRepository;

  final HealthRepository _healthRepository;
  final StepRepositoryImpl _stepRepository;

  /// -----------------------------------------
  /// Health Connect → Supabase 동기화
  /// -----------------------------------------
  Future<void> syncTodaySteps({
    required String userId,
  }) async {
    try {
      final permission =
          await _healthRepository.requestPermission();

      if (!permission) {
        debugPrint("Health 권한 거부");
        return;
      }

      final steps =
          await _healthRepository.getTodaySteps();

      final distance =
          await _healthRepository.getTodayDistanceKm();

      await _stepRepository.saveDailySteps(
        userId: userId,
        date: DateTime.now(),
        steps: steps,
        distanceKm: distance,
      );

      debugPrint(
        "오늘 걸음수 저장 완료 : "
        "$steps 걸음 / ${distance.toStringAsFixed(2)} km",
      );
    } catch (e, s) {
      debugPrint("StepSync Error");
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }
}
