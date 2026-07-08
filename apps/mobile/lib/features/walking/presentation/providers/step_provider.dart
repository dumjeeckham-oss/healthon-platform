import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/step_repository_impl.dart';

/// Repository
final stepRepositoryProvider = Provider<StepRepositoryImpl>(
  (ref) => StepRepositoryImpl(),
);

/// 오늘 걸음수
final todayStepProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(stepRepositoryProvider);

  return repository.getTodaySteps();
});

/// 이번 주 평균
final weeklyAverageProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(stepRepositoryProvider);

  final list = await repository.getWeeklySteps("demo_user");

  if (list.isEmpty) {
    return 0;
  }

  final total = list.reduce((a, b) => a + b);

  return (total / list.length).round();
});

/// 오늘 거리(km)
final distanceProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(stepRepositoryProvider);

  final steps = await repository.getTodaySteps();

  return steps * 0.0007;
});

/// 목표 달성률
final goalRateProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(stepRepositoryProvider);

  final steps = await repository.getTodaySteps();

  const goal = 10000;

  return (steps / goal).clamp(0, 1);
});
