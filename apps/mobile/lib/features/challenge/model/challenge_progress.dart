class ChallengeProgress {
  final int totalSteps;

  const ChallengeProgress({
    required this.totalSteps,
  });

  bool get completed50K => totalSteps >= 50000;

  bool get completed100K => totalSteps >= 100000;

  bool get completed200K => totalSteps >= 200000;

  double get progress50 =>
      (totalSteps / 50000).clamp(0, 1);

  double get progress100 =>
      (totalSteps / 100000).clamp(0, 1);

  double get progress200 =>
      (totalSteps / 200000).clamp(0, 1);
}
