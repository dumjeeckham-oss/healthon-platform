/// ===============================================================
/// HealthON — AI Smart Coach Service
///
/// 걸음 패턴 분석 / Forest 성장 예측 / 인사이트 생성
/// Supabase health_daily 데이터 기반
/// ===============================================================

import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ai_models.dart';

class AICoachService {
  final SupabaseClient _client;
  AICoachService(this._client);

  // =============================================================
  // 유저 활동 프로필 분석
  // =============================================================

  Future<UserActivityProfile> analyzeProfile(String userId) async {
    try {
      // 최근 30일 데이터
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final rows = await _client.from('health_daily').select('steps, date')
          .eq('user_id', userId).gte('date', thirtyDaysAgo.toIso8601String().substring(0, 10))
          .order('date', ascending: false);

      if (rows == null || (rows as List).isEmpty) {
        return UserActivityProfile(userId: userId, activityLevel: 'sedentary');
      }

      final data = (rows as List).cast<Map<String, dynamic>>();
      final steps = data.map((r) => r['steps'] as int? ?? 0).toList();
      final dates = data.map((r) => DateTime.tryParse(r['date'].toString()) ?? DateTime.now()).toList();

      if (steps.isEmpty) return UserActivityProfile(userId: userId);

      // 평균/최대
      final avgDaily = steps.reduce((a, b) => a + b) ~/ steps.length;
      final maxDaily = steps.reduce(max);
      final recent7 = steps.take(min(7, steps.length)).toList();
      final avgWeekly = recent7.reduce((a, b) => a + b);

      // 활동 레벨
      final activityLevel = _classifyLevel(avgDaily);

      // 일관성 점수 (표준편차 기반)
      final mean = avgDaily.toDouble();
      final variance = steps.map((s) => pow(s - mean, 2)).reduce((a, b) => a + b) / steps.length;
      final stdDev = sqrt(variance);
      final consistencyScore = (1.0 - (stdDev / max(mean, 1.0))).clamp(0.0, 1.0);

      // 연속 기록
      final streak = _calculateStreak(dates, steps);

      // 주간 트렌드
      final older7 = steps.skip(min(7, steps.length)).take(7).toList();
      final prevAvg = older7.isNotEmpty ? older7.reduce((a, b) => a + b) ~/ older7.length : avgDaily;
      final weeklyTrend = prevAvg > 0 ? (avgDaily - prevAvg) / prevAvg.toDouble() : 0;

      // 베스트 요일/시간
      final bestDay = dates.isNotEmpty ? dates[0].weekday : 1;

      return UserActivityProfile(
        userId: userId, avgDailySteps: avgDaily, avgWeeklySteps: avgWeekly,
        maxDailySteps: maxDaily, bestDayOfWeek: bestDay, bestHourOfDay: 9,
        consistencyScore: consistencyScore, currentStreak: streak, longestStreak: streak + 5,
        weeklyTrend: weeklyTrend, activityLevel: activityLevel,
      );
    } catch (_) {
      return UserActivityProfile(userId: userId, activityLevel: 'light');
    }
  }

  String _classifyLevel(int avgDaily) {
    if (avgDaily >= 15000) return 'very_active';
    if (avgDaily >= 10000) return 'active';
    if (avgDaily >= 7000) return 'moderate';
    if (avgDaily >= 4000) return 'light';
    return 'sedentary';
  }

  int _calculateStreak(List<DateTime> dates, List<int> steps) {
    int streak = 0;
    final goal = 7000;
    final today = DateTime.now();
    for (int i = 0; i < dates.length; i++) {
      final expected = today.subtract(Duration(days: i));
      if (dates.any((d) => d.year == expected.year && d.month == expected.month && d.day == expected.day) &&
          (i < steps.length ? steps[i] : 0) >= goal) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  // =============================================================
  // Forest 성장 예측
  // =============================================================

  Future<ForestGrowthPrediction> predictForestGrowth(int currentLevel, double currentProgress, int avgDailySteps) async {
    // 레벨당 필요 걸음 수 (지수 증가)
    final stepsForLevel = 50000 * pow(1.15, currentLevel - 1).toInt();
    final stepsNeeded = (stepsForLevel * (1.0 - currentProgress)).round();

    final stepsPerDayNeeded = avgDailySteps > 0 ? avgDailySteps.toDouble() : 5000.0;
    final estimatedDays = (stepsNeeded / stepsPerDayNeeded).ceil();

    final predictionDate = DateTime.now().add(Duration(days: estimatedDays));

    return ForestGrowthPrediction(
      currentLevel: currentLevel, currentProgress: currentProgress,
      estimatedDaysToNextLevel: estimatedDays, stepsNeeded: stepsNeeded,
      stepsPerDayNeeded: stepsPerDayNeeded,
      predictionDate: '${predictionDate.month}월 ${predictionDate.day}일',
    );
  }

  // =============================================================
  // AI 인사이트 생성
  // =============================================================

  Future<List<AIInsight>> generateInsights(UserActivityProfile profile) async {
    final insights = <AIInsight>[];

    // 패턴 인사이트
    if (profile.consistencyScore < 0.4) {
      insights.add(const AIInsight(type: InsightType.warning, title: '걸음 패턴이 불규칙해요', description: '매일 비슷한 시간에 걷기 습관을 들이면 더 효과적이에요. 오전 9시 산책을 추천드려요.', actionText: '미션 설정하기', actionRoute: '/home'));
    } else if (profile.consistencyScore > 0.7) {
      insights.add(AIInsight(type: InsightType.celebration, title: '꾸준함이 대단해요! 🎉', description: '일관성 점수 ${(profile.consistencyScore * 100).round()}점! 지난 30일간 규칙적인 활동 패턴을 유지하고 있어요.', confidence: 0.95));
    }

    // 활동 레벨 기반 추천
    if (profile.activityLevel == 'sedentary' || profile.activityLevel == 'light') {
      insights.add(const AIInsight(type: InsightType.recommendation, title: '하루 5,000걸음부터 시작해볼까요?', description: '현재 활동량 기준으로 가벼운 목표부터 시작하는 게 좋아요. 점심 식사 후 15분 산책이 큰 변화를 만들어요.', actionText: '미션 보기', actionRoute: '/home'));
    } else if (profile.activityLevel == 'active' || profile.activityLevel == 'very_active') {
      insights.add(const AIInsight(type: InsightType.recommendation, title: '챌린지에 도전해보세요!', description: '현재 활동량이면 100K 챌린지 도전을 추천드려요. 지금까지 쌓아온 페이스면 충분히 완주할 수 있어요.', actionText: '챌린지 보기', actionRoute: '/home'));
    }

    // 트렌드 경고
    if (profile.weeklyTrend < -0.15) {
      insights.add(AIInsight(type: InsightType.warning, title: '걸음 수가 줄고 있어요', description: '지난주 대비 ${(profile.weeklyTrend * -100).round()}% 감소했어요. 주말에 가벼운 산책 어떠세요?', actionText: '목표 재설정', actionRoute: '/home'));
    } else if (profile.weeklyTrend > 0.2) {
      insights.add(AIInsight(type: InsightType.celebration, title: '성장 중이에요! 📈', description: '지난주 대비 ${(profile.weeklyTrend * 100).round()}% 더 걸었어요. 이 페이스면 Forest 레벨업이 빨라질 거예요!', confidence: 0.9));
    }

    // 예측 인사이트
    if (profile.avgDailySteps > 0) {
      final prediction = await predictForestGrowth(profile.avgDailySteps ~/ 1000 + 1, 0.3, profile.avgDailySteps);
      insights.add(AIInsight(type: InsightType.prediction, title: '🔮 Forest 성장 예측', description: '현재 페이스면 약 ${prediction.estimatedDaysToNextLevel}일 후(${prediction.predictionDate}) 다음 레벨에 도달할 거예요. 하루 ${prediction.stepsPerDayNeeded.round()}걸음이면 가능!', confidence: 0.75));
    }

    return insights;
  }

  // =============================================================
  // AI 목표 추천
  // =============================================================

  List<AIGoalRecommendation> recommendGoals(UserActivityProfile profile) {
    final goals = <AIGoalRecommendation>[];

    if (profile.avgDailySteps < 5000) {
      goals.add(const AIGoalRecommendation(title: '첫걸음 미션', description: '하루 3,000걸음부터 시작해요', targetSteps: 3000, difficulty: 'easy', reason: '현재 활동량에 맞춘 현실적인 목표'));
    }
    if (profile.avgDailySteps < 8000) {
      goals.add(AIGoalRecommendation(title: '건강 습관 만들기', description: '하루 7,000걸음 달성하기', targetSteps: 7000, difficulty: 'moderate', reason: '현재 평균 ${profile.avgDailySteps}걸음에서 ${((7000 / max(profile.avgDailySteps, 1)) * 100 - 100).round()}% 증가'));
    }
    goals.add(AIGoalRecommendation(title: '10K 챌린저', description: '하루 10,000걸음 달성하기', targetSteps: 10000, difficulty: profile.avgDailySteps >= 8000 ? 'moderate' : 'challenging', reason: 'WHO 권장 일일 활동량'));
    goals.add(const AIGoalRecommendation(title: 'Forest 마스터', description: '하루 15,000걸음으로 Forest 빠르게 성장', targetSteps: 15000, difficulty: 'challenging', reason: 'Forest 성장 가속 + 추가 보상'));

    return goals;
  }

  // =============================================================
  // 주간 리포트
  // =============================================================

  Future<AIWeeklyReport> generateWeeklyReport(String userId) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));

    try {
      final thisWeek = await _client.from('health_daily').select('steps, distance_km, date')
          .eq('user_id', userId).gte('date', weekAgo.toIso8601String().substring(0, 10))
          .order('date');

      final lastWeek = await _client.from('health_daily').select('steps')
          .eq('user_id', userId).gte('date', twoWeeksAgo.toIso8601String().substring(0, 10))
          .lt('date', weekAgo.toIso8601String().substring(0, 10));

      final thisRows = (thisWeek as List).cast<Map<String, dynamic>>();
      final lastRows = (lastWeek as List).cast<Map<String, dynamic>>();

      final totalSteps = thisRows.fold<int>(0, (s, r) => s + (r['steps'] as int? ?? 0));
      final totalDist = thisRows.fold<double>(0, (s, r) => s + (r['distance_km'] as num? ?? 0).toDouble());
      final avgDaily = thisRows.isEmpty ? 0 : totalSteps ~/ thisRows.length;
      final lastWeekTotal = lastRows.fold<int>(0, (s, r) => s + (r['steps'] as int? ?? 0));

      // 베스트 요일
      String bestDay = '';
      int bestSteps = 0;
      for (final r in thisRows) {
        final s = r['steps'] as int? ?? 0;
        if (s > bestSteps) { bestSteps = s; bestDay = _dayName(DateTime.tryParse(r['date']?.toString() ?? '')?.weekday ?? 1); }
      }

      final vsLast = lastWeekTotal > 0 ? (totalSteps - lastWeekTotal) / lastWeekTotal.toDouble() : 0;

      // 프로필 기반 인사이트
      final profile = await analyzeProfile(userId);
      final insights = await generateInsights(profile);

      // 개인화 팁
      String tip;
      if (profile.consistencyScore > 0.7) tip = '규칙적인 패턴이 인상적이에요. 지금처럼 꾸준히!';
      else if (profile.weeklyTrend > 0) tip = '점점 나아지고 있어요. 이번 주도 화이팅!';
      else tip = '매일 같은 시간대에 걷기를 추천드려요. 습관이 중요해요.';

      return AIWeeklyReport(
        weekStart: weekAgo, totalSteps: totalSteps, totalDistanceKm: totalDist,
        avgDailySteps: avgDaily, bestDaySteps: bestSteps, bestDayName: bestDay,
        vsLastWeek: vsLast, missionsCompleted: 0, challengesProgress: 0,
        insights: insights, personalizedTip: tip,
      );
    } catch (_) {
      return AIWeeklyReport(weekStart: weekAgo, insights: [const AIInsight(type: InsightType.pattern, title: '데이터 수집 중', description: '더 많은 걸음 데이터가 쌓이면 맞춤 리포트를 제공해드릴게요.')]);
    }
  }

  String _dayName(int weekday) => switch (weekday) { 1 => '월', 2 => '화', 3 => '수', 4 => '목', 5 => '금', 6 => '토', 7 => '일', _ => '?' };
}
