class HomeState {
  final bool loading;

  final bool syncing;

  final int todaySteps;

  final int weeklySteps;

  final int monthlySteps;

  final double distanceKm;

  final double calories;

  final DateTime? lastSync;

  final String? error;

  const HomeState({
    required this.loading,
    required this.syncing,
    required this.todaySteps,
    required this.weeklySteps,
    required this.monthlySteps,
    required this.distanceKm,
    required this.calories,
    this.lastSync,
    this.error,
  });

  factory HomeState.initial() {
    return const HomeState(
      loading: true,
      syncing: false,
      todaySteps: 0,
      weeklySteps: 0,
      monthlySteps: 0,
      distanceKm: 0,
      calories: 0,
      lastSync: null,
      error: null,
    );
  }

  HomeState copyWith({
    bool? loading,
    bool? syncing,
    int? todaySteps,
    int? weeklySteps,
    int? monthlySteps,
    double? distanceKm,
    double? calories,
    DateTime? lastSync,
    String? error,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      syncing: syncing ?? this.syncing,
      todaySteps: todaySteps ?? this.todaySteps,
      weeklySteps: weeklySteps ?? this.weeklySteps,
      monthlySteps: monthlySteps ?? this.monthlySteps,
      distanceKm: distanceKm ?? this.distanceKm,
      calories: calories ?? this.calories,
      lastSync: lastSync ?? this.lastSync,
      error: error,
    );
  }
}
