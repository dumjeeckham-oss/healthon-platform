/// ===============================================================
/// HealthON Phase 9 ? Smart Challenge Matcher
///
/// AI 기반 챌린지 추천
/// - 사용자 레벨에 맞는 챌린지 매칭
/// - 완주 확률 예측
/// - 페이스 분석
/// ===============================================================

library;

import 'ai_models.dart';

class SmartChallengeMatcher {
  // =============================================================
  // 추천 챌린지 목록
  // =============================================================

  static const _challenges = [
    ChallengeTemplate(id: 'starter_5k', title: '시작이 반! 5,000걸음', target: 5000, difficulty: 'easy', minLevel: 'sedentary', durationDays: 7, description: '매일 5,000걸음으로 시작하는 7일 챌린지', reward: '?? 새싹 뱃지 + 50 EXP'),
    ChallengeTemplate(id: 'daily_7k', title: '건강 습관 7,000걸음', target: 7000, difficulty: 'easy', minLevel: 'light', durationDays: 14, description: '2주 동안 매일 7,000걸음 습관 만들기', reward: '? 건강 뱃지 + 100 EXP'),
    ChallengeTemplate(id: '10k_master', title: '10K 마스터', target: 10000, difficulty: 'moderate', minLevel: 'moderate', durationDays: 21, description: '3주 동안 매일 10,000걸음', reward: '?? 10K 뱃지 + 200 EXP'),
    ChallengeTemplate(id: 'weekend_warrior', title: '주말 전사', target: 15000, difficulty: 'moderate', minLevel: 'moderate', durationDays: 2, description: '주말 동안 하루 15,000걸음!', reward: '?? 주말 전사 뱃지 + 150 EXP'),
    ChallengeTemplate(id: '100k_marathon', title: '100K 마라톤', target: 100000, difficulty: 'challenging', minLevel: 'active', durationDays: 14, description: '2주 동안 총 100,000걸음 달성', reward: '?? 마라토너 뱃지 + 500 EXP'),
    ChallengeTemplate(id: '300k_grand', title: '그랜드 300K', target: 300000, difficulty: 'challenging', minLevel: 'active', durationDays: 30, description: '한 달 300,000걸음! 하루 10,000걸음 페이스', reward: '?? 챔피언 뱃지 + 1000 EXP'),
    ChallengeTemplate(id: 'mountain_climb', title: '?? 산 정복', target: 50000, difficulty: 'moderate', minLevel: 'moderate', durationDays: 3, description: '3일 동안 50,000걸음으로 산 정복!', reward: '?? 등산 뱃지 + 300 EXP'),
  ];

  // =============================================================
  // 챌린지 추천
  // =============================================================

  List<ChallengeMatch> recommendChallenges({
    required UserActivityProfile profile,
    required List<String> completedIds,
    required List<String> activeIds,
  }) {
    final matches = <ChallengeMatch>[];

    for (final challenge in _challenges) {
      // 이미 완료했거나 진행 중이면 제외
      if (completedIds.contains(challenge.id) || activeIds.contains(challenge.id)) {
        continue;
      }

      // 활동 레벨 체크
      if (!_canTakeChallenge(profile.activityLevel, challenge.minLevel)) {
        continue;
      }

      // 완주 확률 계산
      final probability = _calculateCompletionProbability(profile, challenge);
      final paceScore = _calculatePaceScore(profile, challenge);

      matches.add(ChallengeMatch(
        template: challenge,
        completionProbability: probability,
        paceScore: paceScore,
        recommendedDays: _recommendStartDay(profile, challenge),
      ));
    }

    // 완주 확률 높은 순 + 난이도 쉬운 순 정렬
    matches.sort((a, b) {
      final probCompare = b.completionProbability.compareTo(a.completionProbability);
      if (probCompare != 0) return probCompare;
      return a.template.difficulty.compareTo(b.template.difficulty);
    });

    return matches.take(5).toList();
  }

  // =============================================================
  // 완주 확률 계산
  // =============================================================

  double _calculateCompletionProbability(UserActivityProfile profile, ChallengeTemplate challenge) {
    final dailyNeeded = challenge.target / challenge.durationDays;

    // 기본 확률: 평균 걸음 / 필요 걸음
    double probability = (profile.avgDailySteps / dailyNeeded).clamp(0.0, 1.5);

    // 일관성 보너스
    if (profile.consistencyScore > 0.7) { probability *= 1.2; }
    else if (profile.consistencyScore < 0.3) { probability *= 0.8; }

    // 연속 기록 보너스
    if (profile.currentStreak >= 21) { probability *= 1.15; }
    else if (profile.currentStreak >= 7) { probability *= 1.05; }

    // 상승 추세 보너스
    if (profile.weeklyTrend > 0.15) probability *= 1.1;

    // 하락 추세 패널티
    if (profile.weeklyTrend < -0.1) probability *= 0.85;

    return probability.clamp(0.0, 1.0);
  }

  // =============================================================
  // 페이스 점수 (0-100)
  // =============================================================

  double _calculatePaceScore(UserActivityProfile profile, ChallengeTemplate challenge) {
    final dailyNeeded = challenge.target / challenge.durationDays;
    final currentPace = profile.avgDailySteps.toDouble();

    if (dailyNeeded <= 0) return 0;

    final ratio = currentPace / dailyNeeded;
    return (ratio * 50).clamp(0.0, 100.0);
  }

  // =============================================================
  // 활동 레벨 체크
  // =============================================================

  bool _canTakeChallenge(String userLevel, String minLevel) {
    const levels = ['sedentary', 'light', 'moderate', 'active', 'very_active'];
    final userIdx = levels.indexOf(userLevel);
    final minIdx = levels.indexOf(minLevel);
    return userIdx >= minIdx;
  }

  // =============================================================
  // 시작 추천일
  // =============================================================

  String _recommendStartDay(UserActivityProfile profile, ChallengeTemplate challenge) {
    final today = DateTime.now();
    final weekday = today.weekday;

    // 주말 챌린지는 금요일 추천
    if (challenge.durationDays <= 3) {
      if (weekday <= 5) {
        return '이번 주 금요일부터 시작!';
      }
      return '오늘부터 바로 시작!';
    }

    // 장기 챌린지는 월요일 추천
    if (challenge.durationDays >= 14 && weekday > 1) {
      final daysToMonday = (8 - weekday) % 7;
      final nextMonday = today.add(Duration(days: daysToMonday == 0 ? 7 : daysToMonday));
      return '${nextMonday.month}월 ${nextMonday.day}일(월)부터 시작 추천!';
    }

    return '바로 시작하기 좋은 타이밍이에요!';
  }
}

// ===============================================================
// 내부 모델
// ===============================================================

class ChallengeTemplate {
  final String id;
  final String title;
  final int target;
  final String difficulty;
  final String minLevel;
  final int durationDays;
  final String description;
  final String reward;

  const ChallengeTemplate({
    required this.id, required this.title, required this.target,
    required this.difficulty, required this.minLevel, required this.durationDays,
    required this.description, required this.reward,
  });
}

// ===============================================================
// 챌린지 추천 결과
// ===============================================================

class ChallengeMatch {
  final ChallengeTemplate template;
  final double completionProbability;
  final double paceScore;
  final String recommendedDays;

  const ChallengeMatch({
    required this.template,
    this.completionProbability = 0.5,
    this.paceScore = 50,
    this.recommendedDays = '',
  });

  // 외부 노출용 getter
  String get id => template.id;
  String get title => template.title;
  int get target => template.target;
  String get difficulty => template.difficulty;
  int get durationDays => template.durationDays;
  String get description => template.description;
  String get reward => template.reward;

  String get difficultyLabel => switch (difficulty) {
    'easy' => '쉬움', 'moderate' => '보통', 'challenging' => '도전', _ => '보통',
  };

  String get probabilityLabel {
    if (completionProbability >= 0.9) return '매우 높음 ??';
    if (completionProbability >= 0.7) return '높음 ??';
    if (completionProbability >= 0.5) return '보통 ??';
    if (completionProbability >= 0.3) return '낮음 ??';
    return '어려움 ??';
  }
}
