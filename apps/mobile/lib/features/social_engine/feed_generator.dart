import 'package:supabase_flutter/supabase_flutter.dart';

import 'activity_models.dart';
import 'activity_engine.dart';
import '../community/domain/models/community_post.dart';

/// ===============================================================
/// HealthON — Feed Generator
///
/// ActivityEvent → CommunityPost 자동 생성
/// ===============================================================

class FeedGenerator {
  FeedGenerator(this._client);

  final SupabaseClient _client;
  static const String _postTable = 'community_posts';

  /// ActivityEvent → CommunityPost 자동 생성
  ///
  /// Returns { 'post_id': String, 'feed_title': String } 또는 null
  Future<Map<String, dynamic>?> generateFromActivity({
    required ActivityEvent event,
    required String userName,
  }) async {
    final engine = ActivityEngine(_client);

    if (!engine.shouldBecomeFeed(event)) return null;

    final title = engine.feedTitle(event, userName);
    final body = engine.feedBody(event);
    final feedType = engine.feedType(event);

    // 게시글 생성
    try {
      final post = CommunityPost(
        id: '', // Supabase gen_random_uuid
        userId: event.userId,
        category: _toCommunityCategory(feedType),
        title: title,
        content: body ?? title,
        images: _buildImages(event),
        walkingSnapshot: _buildWalkingSnapshot(event),
        forestSnapshot: _buildForestSnapshot(event),
        badgeSnapshot: _buildBadgeSnapshot(event),
        visibility: 'public',
        likeCount: 0,
        commentCount: 0,
        bookmarkCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Supabase insert → post ID 반환
      final result = await _client.from(_postTable).insert(post.toMap()).select('id').single();

      final postId = result['id'] as String;

      return {
        'post_id': postId,
        'feed_title': title,
        'feed_type': feedType.name,
      };
    } catch (e) {
      print('FeedGenerator: post insert failed — $e');
      return null;
    }
  }

  /// FeedType → CommunityCategory 매핑
  CommunityCategory _toCommunityCategory(FeedType type) {
    switch (type) {
      case FeedType.walking:
        return CommunityCategory.walking;
      case FeedType.forest:
        return CommunityCategory.forest;
      case FeedType.challenge:
        return CommunityCategory.challenge;
      default:
        return CommunityCategory.free;
    }
  }

  /// 이벤트 데이터 → 이미지 URL 목록
  List<String> _buildImages(ActivityEvent event) {
    final image = event.data['imageUrl'] as String?;
    return image != null ? [image] : [];
  }

  /// 걷기 Snapshot
  Map<String, dynamic>? _buildWalkingSnapshot(ActivityEvent event) {
    if (event.type != ActivityEventType.dailyStepsUpdated) return null;
    return {
      'steps': event.data['steps'] ?? 0,
      'distanceKm': event.data['distanceKm'] ?? 0,
      'calories': event.data['calories'] ?? 0,
    };
  }

  /// Forest Snapshot
  Map<String, dynamic>? _buildForestSnapshot(ActivityEvent event) {
    if (event.type != ActivityEventType.forestLevelUp) return null;
    return {
      'level': event.data['newLevel'] ?? 1,
      'treeName': event.data['treeName'] ?? '새싹',
      'totalSteps': event.data['totalSteps'] ?? 0,
    };
  }

  /// Badge Snapshot
  Map<String, dynamic>? _buildBadgeSnapshot(ActivityEvent event) {
    if (event.type != ActivityEventType.badgeUnlocked) return null;
    return {
      'badgeTitle': event.data['badgeTitle'] ?? '',
      'badgeIcon': event.data['badgeIcon'] ?? '🏅',
    };
  }
}
