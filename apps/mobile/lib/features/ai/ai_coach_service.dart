import '../../walking/data/step_repository_impl.dart';

class AiCoachService {
  final StepRepositoryImpl repository;

  AiCoachService(this.repository);

  /// 오늘 사용자 상태 분석
  Future<String> getDailyMessage(String userId) async {
    final todaySteps = await repository.getTodaySteps();
    final avg7Days = await _getWeeklyAverage(userId);

    // 1. 운동 부족 상태
    if (todaySteps < avg7Days * 0.5) {
      return "오늘은 평소보다 활동이 적어요 🌿 10분만 걸어볼까요?";
    }

    // 2. 정상 상태
    if (todaySteps >= avg7Days) {
      return "좋은 흐름이에요! 오늘도 꾸준히 이어가고 있어요 👣";
    }

    // 3. 조금 부족
    return "조금만 더 움직이면 목표에 가까워져요 💪";
  }

  /// 최근 7일 평균
  Future<int> _getWeeklyAverage(String userId) async {
    final list = await repository.getWeeklySteps(userId);

    if (list.isEmpty) return 3000;

    final sum = list.reduce((a, b) => a + b);
    return (sum / list.length).round();
  }
}