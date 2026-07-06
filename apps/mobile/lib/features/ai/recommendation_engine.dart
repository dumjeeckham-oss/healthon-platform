class RecommendationEngine {

  /// 행동 기반 추천
  String generate(int steps, int avgSteps, int streak) {

    // 부족 상태
    if (steps < avgSteps * 0.5) {
      return "지금 10분만 걸으면 오늘 목표를 달성할 수 있어요 🌿";
    }

    // 연속 기록 유지
    if (streak >= 7) {
      return "7일 연속 성공! 오늘도 기록을 이어가볼까요? 🔥";
    }

    // 기본
    return "작은 걸음이 큰 변화를 만듭니다 👣";
  }
}