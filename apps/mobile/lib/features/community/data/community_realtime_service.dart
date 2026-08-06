/// ===============================================================
/// HealthON — Community Realtime Service
///
/// Supabase Realtime 채널 구독 + 상태 동기화
/// 실시간 게시글/댓글/좋아요/북마크 업데이트
/// ===============================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/community_post.dart';
import '../domain/models/community_comment.dart';

// ===============================================================
// Change Event Types
// ===============================================================

enum RealtimeChangeType { insert, update, delete }

class RealtimePostChange {
  final RealtimeChangeType type;
  final CommunityPost? post;
  final String? postId;
  const RealtimePostChange({required this.type, this.post, this.postId});
}

class RealtimeCommentChange {
  final RealtimeChangeType type;
  final CommunityComment? comment;
  final String? postId;
  final String? commentId;
  const RealtimeCommentChange({required this.type, this.comment, this.postId, this.commentId});
}

class RealtimeLikeChange {
  final String postId;
  final int newCount;
  const RealtimeLikeChange({required this.postId, required this.newCount});
}

class RealtimeBookmarkChange {
  final String postId;
  final int newCount;
  const RealtimeBookmarkChange({required this.postId, required this.newCount});
}

// ===============================================================
// Connection State
// ===============================================================

enum RealtimeConnectionState { disconnected, connecting, connected, reconnecting }

// ===============================================================
// CommunityRealtimeService
// ===============================================================

class CommunityRealtimeService {
  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = {};

  // 상태 스트림
  final _connectionState = ValueNotifier<RealtimeConnectionState>(RealtimeConnectionState.disconnected);
  ValueListenable<RealtimeConnectionState> get connectionState => _connectionState;

  // 이벤트 스트림
  final _postChanges = StreamController<RealtimePostChange>.broadcast();
  final _commentChanges = StreamController<RealtimeCommentChange>.broadcast();
  final _likeChanges = StreamController<RealtimeLikeChange>.broadcast();
  final _bookmarkChanges = StreamController<RealtimeBookmarkChange>.broadcast();

  Stream<RealtimePostChange> get postChanges => _postChanges.stream;
  Stream<RealtimeCommentChange> get commentChanges => _commentChanges.stream;
  Stream<RealtimeLikeChange> get likeChanges => _likeChanges.stream;
  Stream<RealtimeBookmarkChange> get bookmarkChanges => _bookmarkChanges.stream;

  CommunityRealtimeService(this._client);

  // =============================================================
  // Subscribe
  // =============================================================

  Future<void> connect() async {
    _connectionState.value = RealtimeConnectionState.connecting;

    try {
      _subscribeToPosts();
      _subscribeToComments();
      _subscribeToLikes();
      _subscribeToBookmarks();
      _connectionState.value = RealtimeConnectionState.connected;
      debugPrint('CommunityRealtime: connected');
    } catch (e) {
      _connectionState.value = RealtimeConnectionState.disconnected;
      debugPrint('CommunityRealtime: connection failed $e');
    }
  }

  /// 특정 게시글의 댓글만 실시간으로 받기
  void subscribeToPostComments(String postId) {
    if (_channels.containsKey('comments_$postId')) return;

    final channel = _client.channel('comments_$postId');
    channel.onPostgresChanges(
      event: RealtimeChannelEvent.all,
      schema: 'public',
      table: 'community_comments',
      filter: PostgresColumnFilter(column: 'post_id', operator: 'eq', value: postId),
      callback: (payload) {
        _handleCommentPayload(payload, postId);
      },
    ).subscribe();
    _channels['comments_$postId'] = channel;
  }

  void unsubscribePostComments(String postId) {
    final channel = _channels.remove('comments_$postId');
    channel?.unsubscribe();
    _client.removeChannel(channel!);
  }

  // =============================================================
  // Private — Channel Setup
  // =============================================================

  void _subscribeToPosts() {
    final channel = _client.channel('community_posts_realtime');
    channel.onPostgresChanges(
      event: RealtimeChannelEvent.all,
      schema: 'public',
      table: 'community_posts',
      callback: _handlePostPayload,
    ).subscribe();
    _channels['posts'] = channel;
  }

  void _subscribeToComments() {
    final channel = _client.channel('community_comments_realtime');
    channel.onPostgresChanges(
      event: RealtimeChannelEvent.all,
      schema: 'public',
      table: 'community_comments',
      callback: (payload) => _handleCommentPayload(payload, null),
    ).subscribe();
    _channels['comments_all'] = channel;
  }

  void _subscribeToLikes() {
    final channel = _client.channel('community_likes_realtime');
    channel.onPostgresChanges(
      event: RealtimeChannelEvent.all,
      schema: 'public',
      table: 'community_post_likes',
      callback: _handleLikePayload,
    ).subscribe();
    _channels['likes'] = channel;
  }

  void _subscribeToBookmarks() {
    final channel = _client.channel('community_bookmarks_realtime');
    channel.onPostgresChanges(
      event: RealtimeChannelEvent.all,
      schema: 'public',
      table: 'community_bookmarks',
      callback: _handleBookmarkPayload,
    ).subscribe();
    _channels['bookmarks'] = channel;
  }

  // =============================================================
  // Payload Handlers
  // =============================================================

  void _handlePostPayload(RealtimePayload payload) {
    final changeType = _mapType(payload.eventType);

    try {
      if (payload.newRecord != null && changeType != RealtimeChangeType.delete) {
        final post = CommunityPost.fromJson({
          'id': payload.newRecord!['id'],
          'user_id': payload.newRecord!['user_id'],
          'category': payload.newRecord!['category'],
          'title': payload.newRecord!['title'],
          'content': payload.newRecord!['content'],
          'images': payload.newRecord!['images'],
          'like_count': payload.newRecord!['like_count'],
          'comment_count': payload.newRecord!['comment_count'],
          'bookmark_count': payload.newRecord!['bookmark_count'],
          'report_count': payload.newRecord!['report_count'],
          'created_at': payload.newRecord!['created_at'],
          'updated_at': payload.newRecord!['updated_at'],
        });
        _postChanges.add(RealtimePostChange(type: changeType, post: post));
      } else {
        _postChanges.add(RealtimePostChange(type: changeType, postId: payload.oldRecord?['id'] as String?));
      }
    } catch (e) {
      debugPrint('Realtime post handler: $e');
    }
  }

  void _handleCommentPayload(RealtimePayload payload, String? postId) {
    final changeType = _mapType(payload.eventType);

    try {
      final record = changeType == RealtimeChangeType.delete ? payload.oldRecord : payload.newRecord;
      if (record == null) return;

      final cmp = record['created_at'];

      _commentChanges.add(RealtimeCommentChange(
        type: changeType,
        postId: postId ?? record['post_id'] as String?,
        commentId: record['id'] as String?,
        comment: changeType != RealtimeChangeType.delete ? CommunityComment(
          id: record['id'] ?? '',
          postId: record['post_id'] ?? '',
          userId: record['user_id'] ?? '',
          content: record['content'] ?? '',
          likeCount: record['like_count'] as int? ?? 0,
          createdAt: cmp != null ? DateTime.parse(cmp) : DateTime.now(),
        ) : null,
      ));
    } catch (e) {
      debugPrint('Realtime comment handler: $e');
    }
  }

  void _handleLikePayload(RealtimePayload payload) {
    final postId = (payload.newRecord ?? payload.oldRecord)?['post_id'] as String?;
    if (postId == null) return;

    // like_count 직접 읽기보다 count 쿼리 필요
    // 여기서는 변경 이벤트만 전달하고 provider가 refetch
    _likeChanges.add(RealtimeLikeChange(postId: postId, newCount: -1));
  }

  void _handleBookmarkPayload(RealtimePayload payload) {
    final postId = (payload.newRecord ?? payload.oldRecord)?['post_id'] as String?;
    if (postId == null) return;
    _bookmarkChanges.add(RealtimeBookmarkChange(postId: postId, newCount: -1));
  }

  RealtimeChangeType _mapType(String? eventType) => switch (eventType) {
    'INSERT' => RealtimeChangeType.insert,
    'UPDATE' => RealtimeChangeType.update,
    'DELETE' => RealtimeChangeType.delete,
    _ => RealtimeChangeType.update,
  };

  // =============================================================
  // Cleanup
  // =============================================================

  void dispose() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
      _client.removeChannel(channel);
    }
    _channels.clear();
    _postChanges.close();
    _commentChanges.close();
    _likeChanges.close();
    _bookmarkChanges.close();
    _connectionState.dispose();
  }
}

/// PostgresColumnFilter for Supabase realtime filter
class PostgresColumnFilter {
  final String column;
  final String operator;
  final String value;
  const PostgresColumnFilter({required this.column, required this.operator, required this.value});

  Map<String, dynamic> toJson() => {'column': column, 'op': operator, 'value': value};
}

/// RealtimePayload wrapper
class RealtimePayload {
  final String eventType;
  final Map<String, dynamic>? newRecord;
  final Map<String, dynamic>? oldRecord;
  const RealtimePayload({required this.eventType, this.newRecord, this.oldRecord});
}

/// RealtimeChannelEvent
class RealtimeChannelEvent {
  static const String all = '*';
  static const String insert = 'INSERT';
  static const String update = 'UPDATE';
  static const String delete = 'DELETE';
}
