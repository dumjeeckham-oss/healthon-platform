class PredictionEngine {

  /// 내일 활동 예측
  double predictTomorrowSteps(List<int> last7Days) {
    if (last7Days.isEmpty) return 3000;

    final avg = last7Days.reduce((a, b) => a + b) / last7Days.length;

    // 최근 감소 추세 반영
    final trend = (last7Days.last - last7Days.first) / 7;

    return (avg + trend).clamp(500, 15000);
  }

  /// 이탈 위험 판단
  bool isChurnRisk(List<int> last7Days) {
    final avg = last7Days.reduce((a, b) => a + b) / last7Days.length;

    return avg < 1000;
  }

  /// 성장 가능성
  bool isHighPotential(List<int> last7Days) {
    final trend = last7Days.last - last7Days.first;
    return trend > 1000;
  }
}