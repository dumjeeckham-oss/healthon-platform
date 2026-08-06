import 'package:supabase_flutter/supabase_flutter.dart';

import 'activity_models.dart';
import 'activity_engine.dart';
import 'feed_generator.dart';

/// ===============================================================
/// HealthON — Activity Dispatcher
///
/// ActivityEngine 의 pending 이벤트를 주기적으로 처리하여
/// Feed 생성 + Notification 발송
/// ===============================================================

class ActivityDispatcher {
  ActivityDispatcher(this._client);

  final SupabaseClient _client;
  late final ActivityEngine _engine = ActivityEngine(_client);
  late final FeedGenerator _feedGenerator = FeedGenerator(_client);

  bool _running = false;

  /// 미처리 이벤트를 모두 Dispatch
  Future<int> dispatchPending() async {
    if (_running) return 0;
    _running = true;

    try {
      final events = await _engine.getPendingEvents();
      int processed = 0;

      for (final event in events) {
        try {
          await _dispatchOne(event);
          processed++;
        } catch (e) {
          print('ActivityDispatcher: failed to dispatch ${event.id} — $e');
        }
      }

      return processed;
    } finally {
      _running = false;
    }
  }

  /// 단일 이벤트 처리
  Future<void> _dispatchOne(ActivityEvent event) async {
    // 1. 사용자 이름 조회
    final userName = await _getUserName(event.userId);

    // 2. Feed로 변환
    final feedGenerated = await _feedGenerator.generateFromActivity(
      event: event,
      userName: userName,
    );

    String? feedPostId;
    if (feedGenerated != null) {
      feedPostId = feedGenerated['post_id'] as String?;

      // 3. 알림 생성
      await _createNotification(
        userId: event.userId,
        userName: userName,
        event: event,
      );
    }

    // 4. 배치 완료 표시
    await _engine.markDispatched(event.id, feedPostId ?? '');
  }

  /// 사용자 이름 조회
  Future<String> _getUserName(String userId) async {
    try {
      final row = await _client
          .from('profiles')
          .select('name')
          .eq('id', userId)
          .maybeSingle();

      return row?['name'] as String? ?? '사용자';
    } catch (_) {
      return '사용자';
    }
  }

  /// 알림 생성 (RPC 호출)
  Future<void> _createNotification({
    required String userId,
    required String userName,
    required ActivityEvent event,
  }) async {
    final title = _engine.feedTitle(event, userName);

    try {
      await _client.from('community_notifications').insert({
        'user_id': userId,
        'type': event.type.category,
        'title': title,
        'body': _engine.feedBody(event) ?? '',
        'data': {
          'eventId': event.id,
          'eventType': event.type.name,
          'userId': userId,
          'category': event.type.category,
        },
        'is_read': false,
      });
    } catch (e) {
      print('ActivityDispatcher: notification failed — $e');
    }
  }
}
