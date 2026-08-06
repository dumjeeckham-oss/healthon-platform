import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../health/presentation/providers/health_provider.dart';

class HomeState {
  final int todaySteps;
  final double distance;
  final double calories;
  final int thisWeekSteps;
  final int thisMonthSteps;
  final bool loading;

  const HomeState({
    this.todaySteps = 0,
    this.distance = 0,
    this.calories = 0,
    this.thisWeekSteps = 0,
    this.thisMonthSteps = 0,
    this.loading = false,
  });

  HomeState copyWith({
    int? todaySteps,
    double? distance,
    double? calories,
    int? thisWeekSteps,
    int? thisMonthSteps,
    bool? loading,
  }) {
    return HomeState(
      todaySteps: todaySteps ?? this.todaySteps,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      thisWeekSteps: thisWeekSteps ?? this.thisWeekSteps,
      thisMonthSteps: thisMonthSteps ?? this.thisMonthSteps,
      loading: loading ?? this.loading,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  HomeController(this.ref) : super(const HomeState());

  final Ref ref;

  Future<void> load() async {
    state = state.copyWith(loading: true);

    try {
      // 오늘 데이터
      final todayData = await ref.read(healthTodayProvider.future);
      final weekSum = await ref.read(healthWeekProvider.future);
      final monthSum = await ref.read(healthMonthProvider.future);

      state = state.copyWith(
        todaySteps: todayData?.steps ?? 0,
        distance: todayData?.distanceKm ?? 0.0,
        calories: todayData?.calories ?? 0.0,
        thisWeekSteps: weekSum.$1,
        thisMonthSteps: monthSum.$1,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false);
    }
  }
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(ref),
);
