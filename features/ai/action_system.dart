class ActionSystem {

  /// 자동 목표 조정
  int adjustGoal(int currentGoal, double predicted) {
    if (predicted > currentGoal) {
      return (currentGoal * 1.1).round();
    }

    if (predicted < currentGoal * 0.5) {
      return (currentGoal * 0.9).round();
    }

    return currentGoal;
  }

  /// 자동 알림 트리거
  bool shouldNotify(bool churnRisk) {
    return churnRisk;
  }
}