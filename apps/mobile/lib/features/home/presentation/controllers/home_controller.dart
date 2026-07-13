import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../health/presentation/providers/health_provider.dart';

class HomeState {
  final int todaySteps;
  final double distance;
  final double calories;
  final bool loading;

  const HomeState({
    this.todaySteps = 0,
    this.distance = 0,
    this.calories = 0,
    this.loading = false,
  });

  HomeState copyWith({
    int? todaySteps,
    double? distance,
    double? calories,
    bool? loading,
  }) {
    return HomeState(
      todaySteps: todaySteps ?? this.todaySteps,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      loading: loading ?? this.loading,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  HomeController(this.ref) : super(const HomeState());

  final Ref ref;

  Future<void> load() async {
    state = state.copyWith(loading: true);

    final repository =
        ref.read(healthRepositoryProvider);

    final steps =
        await repository.getTodaySteps();

    final distance =
        await repository.estimateDistanceKm();

    final calories =
        await repository.estimateCalories();

    state = state.copyWith(
      todaySteps: steps,
      distance: distance,
      calories: calories,
      loading: false,
    );
  }
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(ref),
);
