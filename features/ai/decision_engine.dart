class DecisionEngine {

  /// 최종 코칭 메시지 결정
  String decide({
    required bool churnRisk,
    required bool highPotential,
    required double predictedSteps,
  }) {

    if (churnRisk) {
      return "최근 활동이 줄어들었어요 🌿 오늘 5분만 걸어볼까요?";
    }

    if (highPotential) {
      return "성장 흐름이에요! 오늘은 기록을 갱신할 수 있어요 🔥";
    }

    if (predictedSteps > 8000) {
      return "좋은 흐름입니다 👣 내일도 이어가 볼까요?";
    }

    return "작은 움직임이 큰 변화를 만듭니다 🌱";
  }
}