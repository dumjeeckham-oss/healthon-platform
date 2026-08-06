/// ===============================================================
/// HealthON Phase 9 — AI Smart Coach Models
///
/// 걸음 패턴 분석 / 예측 / 인사이트 / 추천 모델
/// ===============================================================

// ===============================================================
// 유저 활동 프로필 (AI 분석용)
// ===============================================================

class UserActivityProfile {
  final String userId;
  final int avgDailySteps;
  final int avgWeeklySteps;
  final int maxDailySteps;
  final int bestDayOfWeek;     // 1=월 ~ 7=일
  final int bestHourOfDay;     // 0-23
  final double consistencyScore; // 0-1.0, 높을수록 규칙적
  final int currentStreak;
  final int longestStreak;
  final double weeklyTrend;    // 양수=증가, 음수=감소
  final String activityLevel;  // sedentary, light, moderate, active, very_active

  const UserActivityProfile({
    required this.userId, this.avgDailySteps = 0, this.avgWeeklySteps = 0,
    this.maxDailySteps = 0, this.bestDayOfWeek = 1, this.bestHourOfDay = 9,
    this.consistencyScore = 0, this.currentStreak = 0, this.longestStreak = 0,
    this.weeklyTrend = 0, this.activityLevel = 'light',
  });

  String get activityLevelLabel => switch (activityLevel) {
    'sedentary' => '정적인 편',
    'light' => '가벼운 활동',
    'moderate' => '꾸준한 활동',
    'active' => '활발한 활동',
    'very_active' => '매우 활발',
    _ => '가벼운 활동',
  };

  String get activityLevelEmoji => switch (activityLevel) {
    'sedentary' => '🪑', 'light' => '🚶', 'moderate' => '🏃', 'active' => '💪', 'very_active' => '🔥', _ => '🚶',
  };
}

// ===============================================================
// AI 인사이트
// ===============================================================

enum InsightType { pattern, recommendation, warning, celebration, prediction }

class AIInsight {
  final InsightType type;
  final String title;
  final String description;
  final String? actionText;
  final String? actionRoute;
  final double confidence; // 0-1.0

  const AIInsight({
    required this.type, required this.title, required this.description,
    this.actionText, this.actionRoute, this.confidence = 0.8,
  });

  String get typeEmoji => switch (type) {
    InsightType.pattern => '📊', InsightType.recommendation => '💡',
    InsightType.warning => '⚠️', InsightType.celebration => '🎉',
    InsightType.prediction => '🔮',
  };
}

// ===============================================================
// AI 주간 리포트
// ===============================================================

class AIWeeklyReport {
  final DateTime weekStart;
  final int totalSteps;
  final double totalDistanceKm;
  final int avgDailySteps;
  final int bestDaySteps;
  final String bestDayName;
  final double vsLastWeek;     // 증감률
  final int missionsCompleted;
  final int challengesProgress;
  final List<AIInsight> insights;
  final String? personalizedTip;

  const AIWeeklyReport({
    required this.weekStart, this.totalSteps = 0, this.totalDistanceKm = 0,
    this.avgDailySteps = 0, this.bestDaySteps = 0, this.bestDayName = '',
    this.vsLastWeek = 0, this.missionsCompleted = 0, this.challengesProgress = 0,
    this.insights = const [], this.personalizedTip,
  });
}

// ===============================================================
// AI 목표 추천
// ===============================================================

class AIGoalRecommendation {
  final String title;
  final String description;
  final int targetSteps;
  final String difficulty; // easy, moderate, challenging
  final String reason;
  final double confidence;

  const AIGoalRecommendation({
    required this.title, required this.description,
    required this.targetSteps, this.difficulty = 'moderate',
    required this.reason, this.confidence = 0.8,
  });
}

// ===============================================================
// Forest 성장 예측
// ===============================================================

class ForestGrowthPrediction {
  final int currentLevel;
  final double currentProgress; // 현재 레벨 내 진행률 0-1.0
  final int estimatedDaysToNextLevel;
  final int stepsNeeded;
  final double stepsPerDayNeeded;
  final String predictionDate;

  const ForestGrowthPrediction({
    this.currentLevel = 1, this.currentProgress = 0,
    this.estimatedDaysToNextLevel = 7, this.stepsNeeded = 0,
    this.stepsPerDayNeeded = 0, this.predictionDate = '',
  });
}

// ===============================================================
// 건강 지표 분석
// ===============================================================

class HealthMetricsAnalysis {
  final double weeklyAvgSteps;
  final double weeklyAvgDistance;
  final double weeklyAvgCalories;
  final int weeklyActiveMinutes;
  final double bmiEstimate;
  final String healthScore; // excellent, good, fair, needs_improvement
  final List<String> strengths;
  final List<String> improvements;

  const HealthMetricsAnalysis({
    this.weeklyAvgSteps = 0, this.weeklyAvgDistance = 0,
    this.weeklyAvgCalories = 0, this.weeklyActiveMinutes = 0,
    this.bmiEstimate = 0, this.healthScore = 'fair',
    this.strengths = const [], this.improvements = const [],
  });

  String get healthScoreLabel => switch (healthScore) {
    'excellent' => '최상', 'good' => '양호', 'fair' => '보통', 'needs_improvement' => '개선 필요', _ => '보통',
  };
}
