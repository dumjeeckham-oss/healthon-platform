class AdminAnalyticsService {

  /// 비활성 사용자 감지
  List<String> getInactiveUsers(
    List<Map<String, dynamic>> stepData,
  ) {
    final Map<String, int> userSteps = {};

    for (final row in stepData) {
      final userId = row['user_id'];
      final steps = row['steps'] ?? 0;

      userSteps[userId] = (userSteps[userId] ?? 0) + steps;
    }

    return userSteps.entries
        .where((e) => e.value < 1000)
        .map((e) => e.key)
        .toList();
  }

  /// 평균 걸음
  double getAverageSteps(List<int> steps) {
    if (steps.isEmpty) return 0;
    return steps.reduce((a, b) => a + b) / steps.length;
  }

  /// 참여율
  double getParticipationRate(int active, int total) {
    if (total == 0) return 0;
    return active / total;
  }

  /// 성장 트렌드
  bool isGrowing(List<int> weeklySteps) {
    if (weeklySteps.length < 2) return false;

    final firstHalf =
        weeklySteps.sublist(0, weeklySteps.length ~/ 2);
    final secondHalf =
        weeklySteps.sublist(weeklySteps.length ~/ 2);

    final avg1 =
        firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final avg2 =
        secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    return avg2 > avg1;
  }
}