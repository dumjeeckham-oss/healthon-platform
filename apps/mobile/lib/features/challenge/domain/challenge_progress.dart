import 'package:flutter/foundation.dart';

@immutable
class ChallengeProgress {
  final int totalSteps;

  final int currentGoal;

  final double progress;

  final bool completed50K;

  final bool completed100K;

  final bool completed200K;

  const ChallengeProgress({
    required this.totalSteps,
    required this.currentGoal,
    required this.progress,
    required this.completed50K,
    required this.completed100K,
    required this.completed200K,
  });

  factory ChallengeProgress.fromTotalSteps(int totalSteps) {
    int goal = 50000;

    if (totalSteps >= 50000) {
      goal = 100000;
    }

    if (totalSteps >= 100000) {
      goal = 200000;
    }

    if (totalSteps >= 200000) {
      goal = 200000;
    }

    return ChallengeProgress(
      totalSteps: totalSteps,
      currentGoal: goal,
      progress: (totalSteps / goal).clamp(0, 1),
      completed50K: totalSteps >= 50000,
      completed100K: totalSteps >= 100000,
      completed200K: totalSteps >= 200000,
    );
  }

  int get remainSteps =>
      (currentGoal - totalSteps).clamp(0, currentGoal);

  double get progress50 =>
      (totalSteps / 50000).clamp(0.0, 1.0);

  double get progress100 =>
      (totalSteps / 100000).clamp(0.0, 1.0);

  double get progress200 =>
      (totalSteps / 200000).clamp(0.0, 1.0);
}
