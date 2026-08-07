
import '../domain/models/community_post.dart';
import '../domain/models/community_comment.dart';

/// ===============================================================
/// CommunityPost ↔ Supabase
/// ===============================================================

extension CommunityPostSupabaseMapper on CommunityPost {
  static CommunityPost fromSupabase(Map<String, dynamic> row) {
    return CommunityPost(
      id: row['id'] ?? '',
      userId: row['user_id'] ?? '',
      category: _cat(row['category']),
      title: row['title'] ?? '',
      content: row['content'] ?? '',
      images: _list(row['images']),
      videoUrl: row['video_url'],
      forestSnapshot: _map(row['forest_snapshot']),
      walkingSnapshot: _map(row['walking_snapshot']),
      badgeSnapshot: _map(row['badge_snapshot']),
      location: row['location'],
      latitude: _dbl(row['latitude']),
      longitude: _dbl(row['longitude']),
      visibility: row['visibility'] ?? 'public',
      likeCount: row['like_count'] ?? 0,
      commentCount: row['comment_count'] ?? 0,
      bookmarkCount: row['bookmark_count'] ?? 0,
      reportCount: row['report_count'] ?? 0,
      createdAt: _ts(row['created_at']),
      updatedAt: _ts(row['updated_at']),
    );
  }

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
  static CommunityComment fromSupabase(Map<String, dynamic> row) {
    return CommunityComment(
      id: row['id'] ?? '',
      postId: row['post_id'] ?? '',
      userId: row['user_id'] ?? '',
      parentId: row['parent_id'],
      content: row['content'] ?? '',
      likeCount: row['like_count'] ?? 0,
      createdAt: _ts(row['created_at']),
      updatedAt: row['updated_at'] != null ? _ts(row['updated_at']) : null,
      mentions: _list(row['mentions']),
      images: _list(row['images']),
      gifUrl: row['gif_url'],
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      if (id.isNotEmpty) 'id': id,
      'post_id': postId,
      'user_id': userId,
      'parent_id': parentId,
      'content': content,
      'like_count': likeCount,
      'mentions': mentions,
      'images': images,
      'gif_url': gifUrl,
      'created_at': createdAt.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }
}

// ===============================================================
// Helpers
// ===============================================================

CommunityCategory _cat(dynamic v) {
  switch (v) {
    case 'notice': return CommunityCategory.notice;
    case 'challenge': return CommunityCategory.challenge;
    case 'walking': return CommunityCategory.walking;
    case 'forest': return CommunityCategory.forest;
    case 'health': return CommunityCategory.health;
    case 'photo': return CommunityCategory.photo;
    case 'question': return CommunityCategory.question;
    case 'event': return CommunityCategory.event;
    default: return CommunityCategory.free;
  }
}

List<String> _list(dynamic v) {
  if (v == null) return const [];
  if (v is List) return v.map((e) => e.toString()).toList();
  return const [];
}

Map<String, dynamic>? _map(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
  return null;
}

double? _dbl(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return null;
}

DateTime _ts(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is String) return DateTime.parse(v);
  if (v is DateTime) return v;
  return DateTime.now();
}
