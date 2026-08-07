/// ===============================================================
/// HealthON Phase 9 — AI Notification Engine
///
/// 사용자 패턴 기반 스마트 푸시 알림
/// - 최적 시간대 알림
/// - 이탈 위험 경고
/// - 목표 달성 축하
/// - Forest 성장 알림
/// ===============================================================

library;

import 'dart:math';
import 'ai_models.dart';

class AINotificationEngine {
  // =============================================================
  // 최적 알림 시간 계산
  // =============================================================

  int calculateBestNotificationHour(UserActivityProfile profile) {
    // 활동 패턴 기반 최적 시간
    // 오전형: 7-9시, 오후형: 17-19시
    if (profile.consistencyScore > 0.7) {
      // 규칙적인 유저 → 기존 활동 시간대에 맞춤
      return profile.bestHourOfDay > 0 ? profile.bestHourOfDay : 9;
    }
    // 불규칙 유저 → 오전 9시 기본
    return 9;
  }

  // =============================================================
  // 알림 생성
  // =============================================================

  List<AINotification> generateNotifications({
    required UserActivityProfile profile,
    required int todaySteps,
    required int goalSteps,
    required int currentHour,
    required int currentStreak,
    required int forestLevel,
    required double weeklyTrend,
  }) {
    final notifications = <AINotification>[];

    // 1. 이탈 위험 알림
    if (_isChurnRisk(profile, todaySteps, goalSteps)) {
      notifications.add(AINotification(
        type: AINotificationType.churnRisk,
        title: '오늘 아직 충분히 걷지 않았어요 🚶',
        body: _churnRiskBody(goalSteps, todaySteps),
        priority: AINotificationPriority.high,
        suggestedHour: _suggestHour(currentHour, 18),
        ctaText: '지금 걷기',
        ctaRoute: '/home',
      ));
    }

    // 2. 목표 달성 축하
    if (todaySteps >= goalSteps && currentHour < 22) {
      notifications.add(AINotification(
        type: AINotificationType.goalAchieved,
        title: '🎉 오늘 목표 달성!',
        body: '${todaySteps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음! 대단해요. 내일도 함께해요.',
        priority: AINotificationPriority.medium,
        suggestedHour: min(currentHour + 1, 21),
        ctaText: '기록 보기',
        ctaRoute: '/home',
      ));
    }

    // 3. 연속 기록 알림
    if (currentStreak >= 3 && currentStreak % 3 == 0) {
      notifications.add(AINotification(
        type: AINotificationType.streakMilestone,
        title: '🔥 $currentStreak일 연속 기록!',
        body: currentStreak >= 30
            ? '한 달 동안 매일 걸으셨어요. 정말 놀라운 의지력이에요!'
            : '꾸준함이 쌓이고 있어요. Forest도 함께 자라고 있어요 🌳',
        priority: AINotificationPriority.medium,
        suggestedHour: 9,
        ctaText: 'Forest 보기',
        ctaRoute: '/forest',
      ));
    }

    // 4. Forest 레벨업 임박
    if (forestLevel > 0 && _isNearLevelUp(profile, forestLevel)) {
      notifications.add(AINotification(
        type: AINotificationType.forestGrowth,
        title: '🌳 Forest 레벨업이 코앞이에요!',
        body: '조금만 더 걸으면 다음 레벨 나무가 자라나요. 오늘 산책 어때요?',
        priority: AINotificationPriority.medium,
        suggestedHour: 17,
        ctaText: 'Forest 보기',
        ctaRoute: '/forest',
      ));
    }

    // 5. 아침 동기부여 (오전 7-9시)
    if (currentHour >= 7 && currentHour <= 9 && profile.avgDailySteps > 0) {
      notifications.add(AINotification(
        type: AINotificationType.morningMotivation,
        title: '☀️ 좋은 아침이에요!',
        body: _morningMotivationBody(profile),
        priority: AINotificationPriority.low,
        suggestedHour: 8,
        ctaText: '오늘 미션 보기',
        ctaRoute: '/home',
      ));
    }

    // 6. 주간 리포트 알림 (월요일)
    if (DateTime.now().weekday == 1 && currentHour >= 9) {
      notifications.add(AINotification(
        type: AINotificationType.weeklyReport,
        title: '📊 주간 리포트가 도착했어요',
        body: '지난주 활동을 분석했어요. 얼마나 걸었는지 확인해보세요!',
        priority: AINotificationPriority.low,
        suggestedHour: 10,
        ctaText: '리포트 보기',
        ctaRoute: '/ai-coach',
      ));
    }

    // 7. 활동 감소 경고
    if (weeklyTrend < -0.2) {
      notifications.add(AINotification(
        type: AINotificationType.churnRisk,
        title: '⚠️ 걸음이 줄고 있어요',
        body: '지난주보다 활동이 줄었어요. 오늘은 점심 후 10분만 걸어볼까요?',
        priority: AINotificationPriority.high,
        suggestedHour: 12,
        ctaText: '목표 재설정',
        ctaRoute: '/home',
      ));
    }

    return notifications;
  }

  // =============================================================
  // Private helpers
  // =============================================================

  bool _isChurnRisk(UserActivityProfile profile, int todaySteps, int goal) {
    final hour = DateTime.now().hour;
    // 오후 6시 이후인데 목표의 40% 미만이면 이탈 위험
    if (hour >= 18 && todaySteps < goal * 0.4) return true;
    // 오후 9시 이후인데 목표의 60% 미만
    if (hour >= 21 && todaySteps < goal * 0.6) return true;
    return false;
  }

  String _churnRiskBody(int goal, int steps) {
    final remaining = goal - steps;
    final minutes = (remaining / 100).round();
    if (minutes <= 30) return '목표까지 ${remaining.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음 남았어요. 약 $minutes분이면 가능!';
    return '오늘 목표까지 아직 멀었어요. 저녁 산책으로 하루를 마무리해보세요 🌙';
  }

  String _morningMotivationBody(UserActivityProfile profile) {
    if (profile.currentStreak >= 7) return '${profile.currentStreak}일 연속 기록 중! 오늘도 이어가볼까요? 🔥';
    if (profile.avgDailySteps >= 10000) return '활동량이 정말 좋아요. 오늘도 좋은 하루 보내세요! 💪';
    return '오늘 하루 ${profile.avgDailySteps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음 목표로 시작해볼까요?';
  }

  bool _isNearLevelUp(UserActivityProfile profile, int level) {
    // 하루 5,000걸음 이상이면 레벨업이 가깝다고 판단
    return profile.avgDailySteps >= 5000;
  }

  int _suggestHour(int current, int fallback) {
    // 퇴근 시간대(17-19시)에 맞춰 알림
    if (current < 17) return 17;
    if (current < 19) return 19;
    return fallback;
  }
}

// ===============================================================
// AI 알림 모델
// ===============================================================

enum AINotificationType {
  churnRisk,
  goalAchieved,
  streakMilestone,
  forestGrowth,
  morningMotivation,
  weeklyReport,
  challengeReminder,
  healthTip,
}

enum AINotificationPriority { low, medium, high }

class AINotification {
  final AINotificationType type;
  final String title;
  final String body;
  final AINotificationPriority priority;
  final int suggestedHour;
  final String? ctaText;
  final String? ctaRoute;
  final String? deepLink;

  const AINotification({
    required this.type,
    required this.title,
    required this.body,
    this.priority = AINotificationPriority.medium,
    this.suggestedHour = 9,
    this.ctaText,
    this.ctaRoute,
    this.deepLink,
  });

  String get priorityLabel => switch (priority) {
    AINotificationPriority.high => 'high',
    AINotificationPriority.medium => 'normal',
    AINotificationPriority.low => 'low',
  };
}
