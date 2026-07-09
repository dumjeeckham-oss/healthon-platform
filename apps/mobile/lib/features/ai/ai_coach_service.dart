import '../walking/data/step_repository_impl.dart';

/// ===============================================================
///
/// AI Coach Service
///
/// 사용자의 최근 걸음 데이터를 분석하여
/// 맞춤형 응원 메시지를 생성한다.
///
/// Sprint 2 MVP
///
/// ===============================================================
class AiCoachService {
  final StepRepositoryImpl repository;

  AiCoachService(this.repository);

  /// 오늘의 AI 메시지
  Future<String> getDailyMessage(String userId) async {
    final todaySteps = await repository.getTodaySteps(userId);

    final avg7Days = await repository.getAverageSteps(userId);

    // 데이터가 거의 없는 신규 사용자
    if (avg7Days == 0) {
      return "건강ON에 오신 것을 환영합니다 🌿 오늘 첫 걸음을 시작해볼까요?";
    }

    // 오늘 아직 거의 걷지 않은 경우
    if (todaySteps < avg7Days * 0.5) {
      return "오늘은 평소보다 활동량이 적어요 😊 10분만 걸어도 몸이 훨씬 가벼워집니다.";
    }

    // 평균보다 많이 걷는 경우
    if (todaySteps >= avg7Days) {
      return "좋은 흐름입니다! 👏 오늘도 건강 습관을 잘 이어가고 있어요.";
    }

    // 평균에 조금 못 미치는 경우
    return "조금만 더 걸으면 오늘 목표를 달성할 수 있어요 💪";
  }

  /// 최근 7일 평균
  Future<int> getWeeklyAverage(String userId) async {
    return repository.getAverageSteps(userId);
  }

  /// 오늘 걸음 수
  Future<int> getTodaySteps(String userId) async {
    return repository.getTodaySteps(userId);
  }

  /// 최근 7일 데이터
  Future<List<int>> getWeeklySteps(String userId) async {
    return repository.getWeeklySteps(userId);
  }
}
