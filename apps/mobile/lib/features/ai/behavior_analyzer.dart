class BehaviorAnalyzer {

  /// 운동 감소 감지
  bool isDeclining(List<int> weeklySteps) {
    if (weeklySteps.length < 2) return false;

    final recent = weeklySteps.sublist(weeklySteps.length - 3);
    final previous = weeklySteps.sublist(0, 3);

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final prevAvg = previous.reduce((a, b) => a + b) / previous.length;

    return recentAvg < prevAvg * 0.7;
  }

  /// 습관 형성 여부
  bool isHabitForming(int streak) {
    return streak >= 5;
  }
}