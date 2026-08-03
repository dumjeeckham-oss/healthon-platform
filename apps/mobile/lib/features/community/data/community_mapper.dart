import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';

/// ===============================================================
///
/// HealthON Community Mapper
///
/// Supabase ↔ Domain Model 변환 유틸리티입니다.
///
/// ===============================================================

// ===============================================================
// CommunityPost ↔ Supabase
// ===============================================================

extension CommunityPostSupabaseMapper on CommunityPost {
  /// Supabase Row → CommunityPost
  static CommunityPost fromSupabase(Map<String, dynamic> row) {
    return CommunityPost(
      id: row['id'] ?? '',
      userId: row['user_id'] ?? '',
      category: _categoryFromString(row['category']),
      title: row['title'] ?? '',
      content: row['content'] ?? '',
      images: _listFromJson(row['images']),
      videoUrl: row['video_url'],
      forestSnapshot: _mapFromJsonB(row['forest_snapshot']),
      walkingSnapshot: _mapFromJsonB(row['walking_snapshot']),
      badgeSnapshot: _mapFromJsonB(row['badge_snapshot']),
      location: row['location'],
      latitude: _toDouble(row['latitude']),
      longitude: _toDouble(row['longitude']),
      visibility: row['visibility'] ?? 'public',
      likeCount: row['like_count'] ?? 0,
      commentCount: row['comment_count'] ?? 0,
      bookmarkCount: row['bookmark_count'] ?? 0,
      reportCount: row['report_count'] ?? 0,
      createdAt: _parseTimestamp(row['created_at']),
      updatedAt: _parseTimestamp(row['updated_at']),
    );
  }

  /// CommunityPost → Supabase Map
  Map<String, dynamic> toSupabase() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'category': category.name,
      'title': title,
      'content': content,
      'images': images,
      'video_url': videoUrl,
      'forest_snapshot': forestSnapshot,
      'walking_snapshot': walkingSnapshot,
      'badge_snapshot': badgeSnapshot,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'visibility': visibility,
      'like_count': likeCount,
      'comment_count': commentCount,
      'bookmark_count': bookmarkCount,
      'report_count': reportCount,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }
}

// ===============================================================
// CommunityComment ↔ Supabase
// ===============================================================

extension CommunityCommentSupabaseMapper on CommunityComment {
  /// Supabase Row → CommunityComment
  static CommunityComment fromSupabase(Map<String, dynamic> row) {
    return CommunityComment(
      id: row['id'] ?? '',
      postId: row['post_id'] ?? '',
      userId: row['user_id'] ?? '',
      parentId: row['parent_id'],
      content: row['content'] ?? '',
      likeCount: row['like_count'] ?? 0,
      createdAt: _parseTimestamp(row['created_at']),
      updatedAt: row['updated_at'] != null ? _parseTimestamp(row['updated_at']) : null,
    );
  }

  /// CommunityComment → Supabase Map
  Map<String, dynamic> toSupabase() {
    return {
      if (id.isNotEmpty) 'id': id,
      'post_id': postId,
      'user_id': userId,
      'parent_id': parentId,
      'content': content,
      'like_count': likeCount,
      'created_at': createdAt.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }
}

// ===============================================================
// Internal Helpers
// ===============================================================

CommunityCategory _categoryFromString(dynamic value) {
  switch (value) {
    case 'notice':
      return CommunityCategory.notice;
    case 'challenge':
      return CommunityCategory.challenge;
    case 'walking':
      return CommunityCategory.walking;
    case 'forest':
      return CommunityCategory.forest;
    case 'health':
      return CommunityCategory.health;
    case 'photo':
      return CommunityCategory.photo;
    case 'question':
      return CommunityCategory.question;
    case 'event':
      return CommunityCategory.event;
    default:
      return CommunityCategory.free;
  }
}

List<String> _listFromJson(dynamic value) {
  if (value == null) return const [];
  if (value is List) return value.map((e) => e.toString()).toList();
  return const [];
}

Map<String, dynamic>? _mapFromJsonB(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return null;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return null;
}

DateTime _parseTimestamp(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is String) return DateTime.parse(value);
  if (value is DateTime) return value;
  return DateTime.now();
}
