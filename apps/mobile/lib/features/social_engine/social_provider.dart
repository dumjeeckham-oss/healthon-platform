import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'activity_engine.dart';
import 'activity_dispatcher.dart';
import 'feed_generator.dart';
import 'notification_engine.dart';
import 'timeline_algorithm.dart';
import 'ai_recommendation.dart';
import '../community/domain/models/community_post.dart';
import '../community/data/community_mapper.dart';

// ===============================================================
// Supabase Client
// ===============================================================

final socialSupabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final socialUserIdProvider = Provider<String?>(
  (ref) => Supabase.instance.client.auth.currentUser?.id,
);

// ===============================================================
// Activity Engine
// ===============================================================

final activityEngineProvider = Provider<ActivityEngine>(
  (ref) => ActivityEngine(ref.watch(socialSupabaseProvider)),
);

// ===============================================================
// Feed Generator
// ===============================================================

final feedGeneratorProvider = Provider<FeedGenerator>(
  (ref) => FeedGenerator(ref.watch(socialSupabaseProvider)),
);

// ===============================================================
// Activity Dispatcher
// ===============================================================

final activityDispatcherProvider = Provider<ActivityDispatcher>(
  (ref) => ActivityDispatcher(ref.watch(socialSupabaseProvider)),
);

// ===============================================================
// Notification Engine
// ===============================================================

final notificationEngineProvider = Provider<NotificationEngine>(
  (ref) => NotificationEngine(ref.watch(socialSupabaseProvider)),
);

// ===============================================================
// Timeline Algorithm
// ===============================================================

final timelineAlgorithmProvider = Provider<TimelineAlgorithm>(
  (ref) => TimelineAlgorithm(ref.watch(socialSupabaseProvider)),
);

// ===============================================================
// 통합 타임라인 (전체)
// ===============================================================

final unifiedTimelineProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = ref.watch(socialUserIdProvider);
  final algorithm = ref.watch(timelineAlgorithmProvider);

  return algorithm.getTimeline(viewerUserId: userId);
});

// ===============================================================
// 팔로잉 타임라인
// ===============================================================

final followingTimelineProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = ref.watch(socialUserIdProvider);
  if (userId == null) return [];

  final algorithm = ref.watch(timelineAlgorithmProvider);
  return algorithm.getFollowingTimeline(viewerUserId: userId);
});

// ===============================================================
// Community Feed (원본 community_posts만)
// ===============================================================

final communityFeedProvider = FutureProvider<List<CommunityPost>>((ref) async {
  try {
    final supabase = ref.watch(socialSupabaseProvider);

    final rows = await supabase
        .from('community_posts')
        .select()
        .order('created_at', ascending: false)
        .limit(100);

    if (rows == null || (rows as List).isEmpty) return [];

    return (rows as List)
        .map((e) => CommunityPostSupabaseMapper.fromSupabase(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('communityFeedProvider: $e');
    return [];
  }
});

// ===============================================================
// 미읽음 알림 개수 (배지)
// ===============================================================

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(socialUserIdProvider);
  if (userId == null) return 0;

  final engine = ref.watch(notificationEngineProvider);
  return engine.getUnreadCount(userId);
});

// ===============================================================
// 최근 알림 목록
// ===============================================================

final recentNotificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = ref.watch(socialUserIdProvider);
  if (userId == null) return [];

  final engine = ref.watch(notificationEngineProvider);
  return engine.getRecent(userId);
});

// ===============================================================
// Dispatch Provider — 주기적 배치 처리 트리거
// ===============================================================

class DispatchState {
  final bool isRunning;
  final int lastProcessedCount;
  final DateTime? lastRun;

  const DispatchState({
    this.isRunning = false,
    this.lastProcessedCount = 0,
    this.lastRun,
  });
}

class DispatchNotifier extends StateNotifier<DispatchState> {
  DispatchNotifier(this._dispatcher) : super(const DispatchState());

  final ActivityDispatcher _dispatcher;

  Future<int> run() async {
    state = DispatchState(isRunning: true, lastProcessedCount: state.lastProcessedCount, lastRun: state.lastRun);
    final count = await _dispatcher.dispatchPending();
    state = DispatchState(isRunning: false, lastProcessedCount: count, lastRun: DateTime.now());
    return count;
  }
}

final dispatchProvider = StateNotifierProvider<DispatchNotifier, DispatchState>(
  (ref) => DispatchNotifier(ref.watch(activityDispatcherProvider)),
);

// ===============================================================
// AI Recommendation Engine
// ===============================================================

final aiRecommendationEngineProvider = Provider<AiRecommendationEngine>(
  (ref) => AiRecommendationEngine(ref.watch(socialSupabaseProvider)),
);

final aiRecommendationsProvider = FutureProvider<RecommendationResult>((ref) async {
  final userId = ref.watch(socialUserIdProvider);
  if (userId == null) throw Exception('로그인이 필요합니다');

  final engine = ref.watch(aiRecommendationEngineProvider);
  return engine.generateRecommendations(userId);
});
