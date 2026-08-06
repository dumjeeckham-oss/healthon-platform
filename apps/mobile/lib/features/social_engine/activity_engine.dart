import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'activity_models.dart';
import 'activity_rule.dart';

/// ===============================================================
/// HealthON — Activity Engine
///
/// ActivityEvent 발생 → Supabase 저장 → Dispatch Queue 등록
/// ===============================================================

class ActivityEngine {
  ActivityEngine(this._client);

  final SupabaseClient _client;
  final ActivityRule _rule = ActivityRule();
  final Uuid _uuid = const Uuid();

  static const String _eventTable = 'activity_events';

  /// 이벤트 발생
  ///
  /// [userId] 이벤트 주체
  /// [type] 이벤트 종류
  /// [data] 이벤트 데이터 (steps, level, rank 등)
  Future<String> emit({
    required String userId,
    required ActivityEventType type,
    required Map<String, dynamic> data,
  }) async {
    final event = ActivityEvent(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );

    // Supabase 저장
    await _client.from(_eventTable).insert(event.toSupabase());

    return event.id;
  }

  /// 오늘 걸음 업데이트 이벤트
  Future<void> emitStepsUpdated({
    required String userId,
    required int steps,
    required double distanceKm,
    required double calories,
  }) async {
    await emit(
      userId: userId,
      type: ActivityEventType.dailyStepsUpdated,
      data: {
        'steps': steps,
        'distanceKm': distanceKm,
        'calories': calories,
      },
    );
  }

  /// Forest 레벨업 이벤트
  Future<void> emitForestLevelUp({
    required String userId,
    required int oldLevel,
    required int newLevel,
    required String treeName,
    required int totalSteps,
  }) async {
    await emit(
      userId: userId,
      type: ActivityEventType.forestLevelUp,
      data: {
        'oldLevel': oldLevel,
        'newLevel': newLevel,
        'treeName': treeName,
        'totalSteps': totalSteps,
      },
    );
  }

  /// Challenge 완료 이벤트
  Future<void> emitChallengeCompleted({
    required String userId,
    required String challengeName,
    required double totalKm,
  }) async {
    await emit(
      userId: userId,
      type: ActivityEventType.challengeCompleted,
      data: {
        'challengeName': challengeName,
        'totalKm': totalKm,
      },
    );
  }

  /// Challenge 이정표 이벤트
  Future<void> emitChallengeMilestone({
    required String userId,
    required String challengeName,
    required double progress,
    required double totalKm,
  }) async {
    await emit(
      userId: userId,
      type: ActivityEventType.challengeProgressMilestone,
      data: {
        'challengeName': challengeName,
        'progress': progress,
        'totalKm': totalKm,
      },
    );
  }

  /// Mission 완료 이벤트
  Future<void> emitMissionCompleted({
    required String userId,
    required String missionTitle,
    required String rewardType,
    required int rewardValue,
  }) async {
    await emit(
      userId: userId,
      type: ActivityEventType.missionCompleted,
      data: {
        'missionTitle': missionTitle,
        'rewardType': rewardType,
        'rewardValue': rewardValue,
      },
    );
  }

  /// Badge 획득 이벤트
  Future<void> emitBadgeUnlocked({
    required String userId,
    required String badgeTitle,
    required String badgeIcon,
  }) async {
    await emit(
      userId: userId,
      type: ActivityEventType.badgeUnlocked,
      data: {
        'badgeTitle': badgeTitle,
        'badgeIcon': badgeIcon,
      },
    );
  }

  /// 랭킹 변동 이벤트
  Future<void> emitRankingChanged({
    required String userId,
    required int oldRank,
    required int newRank,
    required String scope,
  }) async {
    await emit(
      userId: userId,
      type: ActivityEventType.rankingChanged,
      data: {
        'oldRank': oldRank,
        'newRank': newRank,
        'scope': scope,
      },
    );
  }

  /// 최근 이벤트 조회 (미배치된 이벤트)
  Future<List<ActivityEvent>> getPendingEvents({int limit = 50}) async {
    final rows = await _client
        .from(_eventTable)
        .select()
        .eq('dispatched', false)
        .order('created_at', ascending: true)
        .limit(limit);

    return (rows as List)
        .map((e) => ActivityEvent.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  /// 이벤트 배치 완료 표시
  Future<void> markDispatched(String eventId, String feedPostId) async {
    await _client
        .from(_eventTable)
        .update({'dispatched': true, 'feed_post_id': feedPostId})
        .eq('id', eventId);
  }

  /// 이벤트가 Feed로 전환될지 판단
  bool shouldBecomeFeed(ActivityEvent event) => _rule.shouldCreateFeed(event);

  FeedType feedType(ActivityEvent event) => _rule.determineFeedType(event);

  String feedTitle(ActivityEvent event, String userName) =>
      _rule.generateFeedTitle(event, userName);

  String? feedBody(ActivityEvent event) => _rule.generateFeedBody(event);
}
