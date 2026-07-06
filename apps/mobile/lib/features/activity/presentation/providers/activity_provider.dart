import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/activity_repository.dart';
import '../../../../core/services/health_service.dart';

/// Repository Provider
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

/// Activity State
class ActivityState {
  final bool isLoading;
  final int todaySteps;
  final double todayDistance;
  final double totalDistance;
  final double goalDistance;
  final DateTime? lastSyncTime;
  final String? errorMessage;

  const ActivityState({
    this.isLoading = false,
    this.todaySteps = 0,
    this.todayDistance = 0,
    this.totalDistance = 0,
    this.goalDistance = 100,
    this.lastSyncTime,
    this.errorMessage,
  });

  double get progress =>
      goalDistance == 0 ? 0 : totalDistance / goalDistance;

  double get progressPercent => progress * 100;

  double get remainingDistance =>
      goalDistance > totalDistance
          ? goalDistance - totalDistance
          : 0;

  ActivityState copyWith({
    bool? isLoading,
    int? todaySteps,
    double? todayDistance,
    double? totalDistance,
    double? goalDistance,
    DateTime? lastSyncTime,
    String? errorMessage,
  }) {
    return ActivityState(
      isLoading: isLoading ?? this.isLoading,
      todaySteps: todaySteps ?? this.todaySteps,
      todayDistance: todayDistance ?? this.todayDistance,
      totalDistance: totalDistance ?? this.totalDistance,
      goalDistance: goalDistance ?? this.goalDistance,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage,
    );
  }
}

/// Activity Provider
class ActivityNotifier extends StateNotifier<ActivityState> {
  ActivityNotifier(this._repository)
      : super(const ActivityState());

  final ActivityRepository _repository;

  Future<void> load({
    required String participantId,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final steps =
          await HealthService.instance.getTodaySteps();

      final distance =
          await HealthService.instance.getTodayDistance();

      final totalDistance =
          await _repository.getTotalDistance(
        participantId: participantId,
      );

      state = state.copyWith(
        isLoading: false,
        todaySteps: steps,
        todayDistance: distance,
        totalDistance: totalDistance,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final activityProvider = StateNotifierProvider<
    ActivityNotifier,
    ActivityState>((ref) {
  return ActivityNotifier(
    ref.read(activityRepositoryProvider),
  );
});
