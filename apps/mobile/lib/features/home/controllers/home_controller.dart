import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../health/data/repositories/health_repository.dart';
import '../../health/services/step_sync_service.dart';
import 'home_state.dart';

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  throw UnimplementedError(
    'HealthRepository와 StepSyncService를 Provider로 연결해주세요.',
  );
});

class HomeController extends StateNotifier<HomeState> {
  HomeController({
    required HealthRepository repository,
    required StepSyncService syncService,
  })  : _repository = repository,
        _syncService = syncService,
        super(HomeState.initial());

  final HealthRepository _repository;

  final StepSyncService _syncService;

  Future<void> initialize() async {
    await refresh();
  }

  Future<void> refresh() async {
    try {
      state = state.copyWith(
        loading: true,
        error: null,
      );

      final today = await _repository.getTodaySteps();

      final weekly = await _repository.getWeeklySteps();

      final monthly = await _repository.getMonthlySteps();

      final distance = await _repository.estimateDistanceKm();

      final calories = await _repository.estimateCalories();

      state = state.copyWith(
        loading: false,
        todaySteps: today,
        weeklySteps: weekly,
        monthlySteps: monthly,
        distanceKm: distance,
        calories: calories,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> syncNow() async {
    try {
      state = state.copyWith(syncing: true);

      await _syncService.syncToday();

      state = state.copyWith(
        syncing: false,
        lastSync: DateTime.now(),
      );

      await refresh();
    } catch (e) {
      state = state.copyWith(
        syncing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> requestHealthPermission() async {
    final granted = await _repository.requestAuthorization();

    if (granted) {
      await refresh();
    } else {
      state = state.copyWith(
        error: 'Health 권한이 허용되지 않았습니다.',
      );
    }
  }
}
