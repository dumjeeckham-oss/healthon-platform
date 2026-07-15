import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../health/presentation/providers/health_provider.dart';

/// ===============================================================
///
/// Walking Providers
///
/// Walking 화면에서 사용하는 Provider를 한 곳에서 관리
///
/// ===============================================================

/// ------------------------------------------------------------
/// 오늘 걸음수
/// ------------------------------------------------------------
final todayStepsProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(healthRepositoryProvider);

  return repository.getTodaySteps();
});

/// ------------------------------------------------------------
/// 오늘 이동거리(km)
/// ------------------------------------------------------------
final distanceProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final repository = ref.read(healthRepositoryProvider);

  return repository.estimateDistanceKm();
});

/// ------------------------------------------------------------
/// 오늘 칼로리
/// ------------------------------------------------------------
final caloriesProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final repository = ref.read(healthRepositoryProvider);

  return repository.estimateCalories();
});

/// ------------------------------------------------------------
/// 최근 7일 걸음수
/// ------------------------------------------------------------
final weeklyStepsProvider =
    FutureProvider.autoDispose<List<int>>((ref) async {
  final repository = ref.read(healthRepositoryProvider);

  return repository.getLast7DaysSteps();
});

/// ------------------------------------------------------------
/// 이번 주 총 걸음수
/// ------------------------------------------------------------
final weeklyTotalProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(healthRepositoryProvider);

  return repository.getWeeklySteps();
});

/// ------------------------------------------------------------
/// 이번 달 총 걸음수
/// ------------------------------------------------------------
final monthlyTotalProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(healthRepositoryProvider);

  return repository.getMonthlySteps();
});
