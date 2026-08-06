/// ===============================================================
/// HealthON Phase 9 — AI Provider (Enhanced)
///
/// AI Coach + Notification Engine + Chatbot + Analytics + Challenge Matcher
/// ===============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ai_models.dart';
import 'ai_coach_service.dart';
import 'ai_notification_engine.dart';
import 'ai_health_chatbot.dart';
import 'health_analytics_engine.dart';
import 'smart_challenge_matcher.dart';

// ===============================================================
// Base providers
// ===============================================================

final aiSupabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);
final aiCoachServiceProvider = Provider<AICoachService>((ref) => AICoachService(ref.watch(aiSupabaseProvider)));
final aiNotificationEngineProvider = Provider<AINotificationEngine>((ref) => AINotificationEngine());
final aiChatbotProvider = Provider<AIHealthChatbot>((ref) => AIHealthChatbot());
final healthAnalyticsProvider = Provider<HealthAnalyticsEngine>((ref) => HealthAnalyticsEngine());
final smartChallengeMatcherProvider = Provider<SmartChallengeMatcher>((ref) => SmartChallengeMatcher());

// 유저 ID
final aiCurrentUserIdProvider = StateProvider<String>((ref) => Supabase.instance.client.auth.currentUser?.id ?? '');

// ===============================================================
// 활동 프로필
// ===============================================================

final aiProfileProvider = FutureProvider<UserActivityProfile>((ref) {
  final userId = ref.watch(aiCurrentUserIdProvider);
  if (userId.isEmpty) throw Exception('로그인 필요');
  return ref.watch(aiCoachServiceProvider).analyzeProfile(userId);
});

// ===============================================================
// AI 인사이트
// ===============================================================

final aiInsightsProvider = FutureProvider<List<AIInsight>>((ref) async {
  final profile = await ref.watch(aiProfileProvider.future);
  return ref.watch(aiCoachServiceProvider).generateInsights(profile);
});

// ===============================================================
// 목표 추천
// ===============================================================

final aiGoalsProvider = Provider<List<AIGoalRecommendation>>((ref) {
  final profile = ref.watch(aiProfileProvider).valueOrNull;
  if (profile == null) return [];
  return ref.watch(aiCoachServiceProvider).recommendGoals(profile);
});

// ===============================================================
// Forest 예측
// ===============================================================

final aiForestPredictionProvider = FutureProvider<ForestGrowthPrediction>((ref) async {
  final profile = await ref.watch(aiProfileProvider.future);
  return ref.watch(aiCoachServiceProvider).predictForestGrowth(
    profile.avgDailySteps ~/ 1000 + 1, 0.3, profile.avgDailySteps,
  );
});

// ===============================================================
// 주간 리포트
// ===============================================================

final aiWeeklyReportProvider = FutureProvider<AIWeeklyReport>((ref) {
  final userId = ref.watch(aiCurrentUserIdProvider);
  if (userId.isEmpty) throw Exception('로그인 필요');
  return ref.watch(aiCoachServiceProvider).generateWeeklyReport(userId);
});

// ===============================================================
// AI 알림 목록
// ===============================================================

final aiNotificationsProvider = Provider<List<AINotification>>((ref) {
  final profile = ref.watch(aiProfileProvider).valueOrNull;
  if (profile == null) return [];

  return ref.watch(aiNotificationEngineProvider).generateNotifications(
    profile: profile,
    todaySteps: 6500, // TODO: 실제 todaySteps Provider에서 가져오기
    goalSteps: 10000,
    currentHour: DateTime.now().hour,
    currentStreak: profile.currentStreak,
    forestLevel: 3,
    weeklyTrend: profile.weeklyTrend,
  );
});

// ===============================================================
// 챌린지 추천
// ===============================================================

final aiChallengeMatchesProvider = Provider<List<ChallengeMatch>>((ref) {
  final profile = ref.watch(aiProfileProvider).valueOrNull;
  if (profile == null) return [];

  return ref.watch(smartChallengeMatcherProvider).recommendChallenges(
    profile: profile,
    completedIds: [],
    activeIds: [],
  );
});

// ===============================================================
// 활동 점수
// ===============================================================

final aiActivityScoreProvider = Provider<int>((ref) {
  // 간소화: 프로필 기반 점수
  final profile = ref.watch(aiProfileProvider).valueOrNull;
  if (profile == null) return 0;

  final stepsLast7 = profile.avgWeeklySteps;
  final stepsLast30 = profile.avgDailySteps * 30;

  return ref.watch(healthAnalyticsProvider).calculateActivityScore(
    stepsLast7Days: List.filled(7, profile.avgDailySteps),
    stepsLast30Days: List.filled(30, profile.avgDailySteps),
    streak: profile.currentStreak,
  );
});

// ===============================================================
// AI 채팅 메시지
// ===============================================================

final aiChatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => [
  const ChatMessage(
    text: '안녕하세요! 건강ON AI 코치입니다 🖐️\n궁금한 점을 물어보세요. 걸음 데이터, 목표 추천, Forest 성장까지 무엇이든 답변해드려요!',
    isUser: false,
    type: ChatMessageType.text,
  ),
]);

final aiChatLoadingProvider = StateProvider<bool>((ref) => false);
