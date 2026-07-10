import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/health_repository.dart';
import '../../data/services/health_service.dart';
import '../../data/services/step_sync_service.dart';

/// ------------------------------------------------------------
/// Services
/// ------------------------------------------------------------

final healthServiceProvider =
    Provider<HealthService>((ref) {
  return HealthService();
});

/// ------------------------------------------------------------
/// Repository
/// ------------------------------------------------------------

final healthRepositoryProvider =
    Provider<HealthRepository>((ref) {
  return HealthRepository(
    ref.read(healthServiceProvider),
  );
});

/// ------------------------------------------------------------
/// Step Sync
/// ------------------------------------------------------------

final stepSyncServiceProvider =
    Provider<StepSyncService>((ref) {
  return StepSyncService(
    ref.read(healthRepositoryProvider),
  );
});

/// ------------------------------------------------------------
/// 오늘 걸음수
/// ------------------------------------------------------------

final todayStepsProvider =
    FutureProvider<int>((ref) async {
  return ref
      .read(healthRepositoryProvider)
      .getTodaySteps();
});

/// ------------------------------------------------------------
/// 거리
/// ------------------------------------------------------------

final todayDistanceProvider =
    FutureProvider<double>((ref) async {
  return ref
      .read(healthRepositoryProvider)
      .estimateDistanceKm();
});

/// ------------------------------------------------------------
/// 칼로리
/// ------------------------------------------------------------

final todayCaloriesProvider =
    FutureProvider<double>((ref) async {
  return ref
      .read(healthRepositoryProvider)
      .estimateCalories();
});

/// ------------------------------------------------------------
/// 최근 7일
/// ------------------------------------------------------------

final weeklyStepsProvider =
    FutureProvider<List<int>>((ref) async {
  return ref
      .read(healthRepositoryProvider)
      .getLast7DaysSteps();
});
