import 'package:flutter/foundation.dart';

/// ===============================================================
/// HealthON — Activity Models
///
/// Social Engine 에서 사용하는 이벤트/피드/알림 모델
/// ===============================================================

// ===============================================================
// Activity Event Type
// ===============================================================

enum ActivityEventType {
  dailyStepsUpdated('오늘 걸음 업데이트', 'steps'),
  forestLevelUp('Forest 레벨업', 'forest'),
  challengeCompleted('Challenge 완료', 'challenge'),
  challengeProgressMilestone('Challenge 이정표', 'challenge'),
  missionCompleted('Mission 완료', 'mission'),
  badgeUnlocked('Badge 획득', 'badge'),
  rankingChanged('랭킹 변동', 'ranking'),
  familyChallengeCompleted('가족 Challenge 완료', 'family'),
  commentCreated('댓글 작성', 'comment'),
  postCreated('게시글 작성', 'post'),
  reactionAdded('리액션 추가', 'reaction'),
  friendAdded('친구 추가', 'friend');

  const ActivityEventType(this.label, this.category);
  final String label;
  final String category;
}

// ===============================================================
// Feed Type
// ===============================================================

enum FeedType {
  normal('일반'),
  walking('걷기'),
  forest('Forest'),
  challenge('Challenge'),
  ranking('랭킹'),
  badge('Badge'),
  family('가족'),
  notice('공지'),
  news('법인소식'),
  system('시스템');

  const FeedType(this.label);
  final String label;
}

// ===============================================================
// Activity Event
// ===============================================================

@immutable
class ActivityEvent {
  final String id;
  final String userId;
  final ActivityEventType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool dispatched;
  final String? feedPostId; // 변환된 Community Post ID

  const ActivityEvent({
    required this.id,
    required this.userId,
    required this.type,
    required this.data,
    required this.createdAt,
    this.dispatched = false,
    this.feedPostId,
  });

  Map<String, dynamic> toSupabase() => {
    'id': id,
    'user_id': userId,
    'type': type.name,
    'data': data,
    'dispatched': dispatched,
    'feed_post_id': feedPostId,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  factory ActivityEvent.fromSupabase(Map<String, dynamic> row) {
    return ActivityEvent(
      id: row['id'] ?? '',
      userId: row['user_id'] ?? '',
      type: ActivityEventType.values.firstWhere(
        (e) => e.name == row['type'],
        orElse: () => ActivityEventType.dailyStepsUpdated,
      ),
      data: (row['data'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {},
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
      dispatched: row['dispatched'] ?? false,
      feedPostId: row['feed_post_id'],
    );
  }
}

// ===============================================================
// Feed Item
// ===============================================================

@immutable
class FeedItem {
  final String id;
  final String? userId;
  final String? actorName;
  final FeedType type;
  final String title;
  final String? body;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? postId; // 연결된 Community Post ID
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;

  const FeedItem({
    required this.id,
    this.userId,
    this.actorName,
    required this.type,
    required this.title,
    this.body,
    this.data,
    this.imageUrl,
    this.postId,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
  });
}

// ===============================================================
// Social Connection
// ===============================================================

@immutable
class SocialConnection {
  final String id;
  final String fromUserId;
  final String toUserId;
  final SocialRelationType relationType;
  final DateTime createdAt;

  const SocialConnection({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.relationType,
    required this.createdAt,
  });
}

enum SocialRelationType {
  follow('팔로우'),
  friend('친구'),
  family('가족');

  const SocialRelationType(this.label);
  final String label;
}
