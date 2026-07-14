class ChallengeSummary {
  final double currentKm;

  final double goalKm;

  /// 0.0 ~ 1.0
  final double progress;

  /// 오늘 목표 거리
  final double todayGoal;

  /// 남은 거리
  final double remainingKm;

  /// 예상 완료일
  final String expectedFinish;

  /// AI 응원 메시지
  final String cheerMessage;

  const ChallengeSummary({
    required this.currentKm,
    required this.goalKm,
    required this.progress,
    required this.todayGoal,
    required this.remainingKm,
    required this.expectedFinish,
    required this.cheerMessage,
  });

  /// 퍼센트(0~100)
  double get progressPercent => progress * 100;

  /// 완료 여부
  bool get completed => progress >= 1.0;

  /// 현재 레벨
  int get level {
    if (currentKm >= 200) return 4;
    if (currentKm >= 100) return 3;
    if (currentKm >= 50) return 2;
    return 1;
  }

  /// 레벨명
  String get levelName {
    switch (level) {
      case 1:
        return "새싹";
      case 2:
        return "푸른나무";
      case 3:
        return "숲";
      case 4:
        return "건강마스터";
      default:
        return "새싹";
    }
  }

  factory ChallengeSummary.empty() {
    return const ChallengeSummary(
      currentKm: 0,
      goalKm: 100,
      progress: 0,
      todayGoal: 3,
      remainingKm: 100,
      expectedFinish: "-",
      cheerMessage: "오늘도 건강하게 걸어볼까요?",
    );
  }

  ChallengeSummary copyWith({
    double? currentKm,
    double? goalKm,
    double? progress,
    double? todayGoal,
    double? remainingKm,
    String? expectedFinish,
    String? cheerMessage,
  }) {
    return ChallengeSummary(
      currentKm: currentKm ?? this.currentKm,
      goalKm: goalKm ?? this.goalKm,
      progress: progress ?? this.progress,
      todayGoal: todayGoal ?? this.todayGoal,
      remainingKm: remainingKm ?? this.remainingKm,
      expectedFinish: expectedFinish ?? this.expectedFinish,
      cheerMessage: cheerMessage ?? this.cheerMessage,
    );
  }
}
