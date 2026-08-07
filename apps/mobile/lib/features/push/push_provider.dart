/// ===============================================================
/// HealthON — Push Notification Provider
///
/// FCM + Local Notifications + Settings + Admin Queue
/// ===============================================================

library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'push_notification_service.dart';

// ===============================================================
// Push Service
// ===============================================================

final pushServiceProvider = Provider<PushNotificationService>((ref) {
  final client = ref.watch(pushSupabaseProvider);
  return PushNotificationService(client);
});

final pushSupabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

// ===============================================================
// 푸시 설정 StateNotifier
// ===============================================================

class PushSettingsNotifier extends StateNotifier<AsyncValue<PushSettings>> {
  final SupabaseClient _client;

  PushSettingsNotifier(this._client) : super(const AsyncValue.loading());

  Future<void> load() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      state = AsyncValue.data(PushSettings.defaults(userId: ''));
      return;
    }
    try {
      final row = await _client.from('notification_settings').select().eq('user_id', userId).maybeSingle();
      state = AsyncValue.data(row != null ? PushSettings.fromSupabase(row) : PushSettings.defaults(userId: userId));
    } catch (e) {
      state = AsyncValue.data(PushSettings.defaults(userId: userId));
    }
  }

  Future<void> update(PushSettings settings) async {
    state.whenData((_) => state = AsyncValue.data(settings));
    try {
      await _client.from('notification_settings').upsert(settings.toSupabase(), onConflict: 'user_id');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> togglePushEnabled(bool value) async {
    state.whenData((s) => update(s.copyWith(pushEnabled: value)));
  }

  Future<void> toggleCategory(String category, bool value) async {
    state.whenData((s) {
      final updated = s.copyWithRaw({category: value});
      update(updated);
    });
  }
}

final pushSettingsProvider = StateNotifierProvider<PushSettingsNotifier, AsyncValue<PushSettings>>((ref) {
  return PushSettingsNotifier(ref.watch(pushSupabaseProvider));
});

// ===============================================================
// 푸시 전송 (관리자용)
// ===============================================================

class PushQueueNotifier extends StateNotifier<AsyncValue<List<PushQueueEntry>>> {
  final SupabaseClient _client;

  PushQueueNotifier(this._client) : super(const AsyncValue.data([]));

  /// 모든 활성 사용자에게 공지 푸시 전송
  Future<int> sendNoticePushToAll({
    required String title,
    required String body,
    required String noticeId,
    String category = 'notice',
    Map<String, dynamic>? data,
  }) async {
    int count = 0;
    try {
      // 활성 토큰 가진 사용자 조회
      final tokens = await _client.from('push_tokens').select('user_id').eq('is_active', true);
      final userIds = (tokens as List).map((t) => (t as Map<String, dynamic>)['user_id'] as String).toList();

      // 큐에 일괄 등록
      final rows = userIds.map((uid) => {
        'user_id': uid,
        'title': title,
        'body': body,
        'data': {'noticeId': noticeId, ...?data},
        'category': category,
        'status': 'pending',
      }).toList();

      // 500건씩 배치 insert
      for (var i = 0; i < rows.length; i += 500) {
        final batch = rows.sublist(i, (i + 500 > rows.length) ? rows.length : i + 500);
        await _client.from('push_notification_queue').insert(batch);
        count += batch.length;
      }

      return count;
    } catch (e) {
      debugPrint('PushQueue sendNoticePushToAll: $e');
      return count;
    }
  }

  /// 단일 사용자에게 푸시 전송
  Future<bool> sendPushToUser({
    required String userId,
    required String title,
    required String body,
    String category = 'general',
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.from('push_notification_queue').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'category': category,
        'status': 'pending',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 보류 중인 큐 조회
  Future<List<PushQueueEntry>> getPendingQueue() async {
    try {
      final rows = await _client.from('push_notification_queue')
          .select().eq('status', 'pending')
          .order('created_at', ascending: true).limit(100);
      return (rows as List).map((e) => PushQueueEntry.fromSupabase(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}

final pushQueueProvider = StateNotifierProvider<PushQueueNotifier, AsyncValue<List<PushQueueEntry>>>((ref) {
  return PushQueueNotifier(ref.watch(pushSupabaseProvider));
});

// ===============================================================
// Models
// ===============================================================

class PushSettings {
  final String userId;
  final bool pushEnabled;
  final bool noticePush;
  final bool challengePush;
  final bool missionPush;
  final bool forestPush;
  final bool communityPush;
  final bool rewardPush;
  final bool reportPush;
  final bool quietHoursEnabled;
  final String quietHoursStart; // HH:MM
  final String quietHoursEnd;   // HH:MM

  const PushSettings({
    required this.userId,
    this.pushEnabled = true,
    this.noticePush = true,
    this.challengePush = true,
    this.missionPush = true,
    this.forestPush = true,
    this.communityPush = true,
    this.rewardPush = true,
    this.reportPush = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
  });

  factory PushSettings.defaults({required String userId}) => PushSettings(userId: userId);

  factory PushSettings.fromSupabase(Map<String, dynamic> row) => PushSettings(
    userId: row['user_id'] ?? '',
    pushEnabled: row['push_enabled'] ?? true,
    noticePush: row['notice_push'] ?? true,
    challengePush: row['challenge_push'] ?? true,
    missionPush: row['mission_push'] ?? true,
    forestPush: row['forest_push'] ?? true,
    communityPush: row['community_push'] ?? true,
    rewardPush: row['reward_push'] ?? true,
    reportPush: row['report_push'] ?? true,
    quietHoursEnabled: row['quiet_hours_enabled'] ?? false,
    quietHoursStart: row['quiet_hours_start'] ?? '22:00',
    quietHoursEnd: row['quiet_hours_end'] ?? '08:00',
  );

  Map<String, dynamic> toSupabase() => {
    'user_id': userId,
    'push_enabled': pushEnabled,
    'notice_push': noticePush,
    'challenge_push': challengePush,
    'mission_push': missionPush,
    'forest_push': forestPush,
    'community_push': communityPush,
    'reward_push': rewardPush,
    'report_push': reportPush,
    'quiet_hours_enabled': quietHoursEnabled,
    'quiet_hours_start': quietHoursStart,
    'quiet_hours_end': quietHoursEnd,
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  };

  bool isCategoryEnabled(String category) => switch (category) {
    'notice' => noticePush,
    'challenge' => challengePush,
    'mission' => missionPush,
    'forest' => forestPush,
    'community' => communityPush,
    'reward' => rewardPush,
    'report' => reportPush,
    _ => true,
  };

  PushSettings copyWith({
    bool? pushEnabled,
    bool? noticePush,
    bool? challengePush,
    bool? missionPush,
    bool? forestPush,
    bool? communityPush,
    bool? rewardPush,
    bool? reportPush,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) => PushSettings(
    userId: userId,
    pushEnabled: pushEnabled ?? this.pushEnabled,
    noticePush: noticePush ?? this.noticePush,
    challengePush: challengePush ?? this.challengePush,
    missionPush: missionPush ?? this.missionPush,
    forestPush: forestPush ?? this.forestPush,
    communityPush: communityPush ?? this.communityPush,
    rewardPush: rewardPush ?? this.rewardPush,
    reportPush: reportPush ?? this.reportPush,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    quietHoursStart: quietHoursStart ?? this.quietHoursStart,
    quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
  );

  PushSettings copyWithRaw(Map<String, dynamic> overrides) => PushSettings(
    userId: userId,
    pushEnabled: overrides['push_enabled'] as bool? ?? pushEnabled,
    noticePush: overrides['notice_push'] as bool? ?? noticePush,
    challengePush: overrides['challenge_push'] as bool? ?? challengePush,
    missionPush: overrides['mission_push'] as bool? ?? missionPush,
    forestPush: overrides['forest_push'] as bool? ?? forestPush,
    communityPush: overrides['community_push'] as bool? ?? communityPush,
    rewardPush: overrides['reward_push'] as bool? ?? rewardPush,
    reportPush: overrides['report_push'] as bool? ?? reportPush,
    quietHoursEnabled: overrides['quiet_hours_enabled'] as bool? ?? quietHoursEnabled,
    quietHoursStart: overrides['quiet_hours_start'] as String? ?? quietHoursStart,
    quietHoursEnd: overrides['quiet_hours_end'] as String? ?? quietHoursEnd,
  );
}

class PushQueueEntry {
  final String id;
  final String userId;
  final String title;
  final String? body;
  final Map<String, dynamic> data;
  final String? imageUrl;
  final String category;
  final String status;
  final String? errorMessage;
  final DateTime? sentAt;
  final DateTime createdAt;

  const PushQueueEntry({
    required this.id,
    required this.userId,
    required this.title,
    this.body,
    this.data = const {},
    this.imageUrl,
    this.category = 'general',
    this.status = 'pending',
    this.errorMessage,
    this.sentAt,
    required this.createdAt,
  });

  factory PushQueueEntry.fromSupabase(Map<String, dynamic> row) => PushQueueEntry(
    id: row['id'] ?? '',
    userId: row['user_id'] ?? '',
    title: row['title'] ?? '',
    body: row['body'],
    data: row['data'] is Map ? Map<String, dynamic>.from(row['data']) : {},
    imageUrl: row['image_url'],
    category: row['category'] ?? 'general',
    status: row['status'] ?? 'pending',
    errorMessage: row['error_message'],
    sentAt: row['sent_at'] != null ? DateTime.parse(row['sent_at']) : null,
    createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
  );
}
