import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../health/presentation/providers/health_provider.dart';
import '../../application/walking_sync_service.dart';

final todayStepsProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(healthRepositoryProvider);
  return repository.getTodaySteps();
});

final distanceProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final repository = ref.read(healthRepositoryProvider);
  return repository.estimateDistanceKm();
});

final caloriesProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final repository = ref.read(healthRepositoryProvider);
  return repository.estimateCalories();
});

final weeklyStepsProvider =
    FutureProvider.autoDispose<List<int>>((ref) async {
  final repository = ref.read(healthRepositoryProvider);
  return repository.getLast7DaysSteps();
});

final weeklyTotalProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(healthRepositoryProvider);
  return repository.getWeeklySteps();
});

final monthlyTotalProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(healthRepositoryProvider);
  return repository.getMonthlySteps();
});
