/// ===============================================================
/// HealthON — Community Realtime Service
/// Supabase Realtime 채널 구독 + 상태 동기화
/// ===============================================================

import 'dart:async';

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

  final Map<String, RealtimeChannel> _commentChannels = {};

  void subscribeToPostComments(String postId) {
    final channel = _client.channel('comments_$postId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'community_comments',
      filter: PostgresChangeFilter(column: 'post_id', type: PostgresChangeFilterType.eq, value: postId),
      callback: (PostgresChangePayload payload) {
        _handleCommentPayload(payload, postId);
      },
    ).subscribe();
    _commentChannels[postId] = channel;
  }

  void unsubscribePostComments(String postId) {
    final channel = _commentChannels.remove(postId);
    if (channel != null) {
      channel.unsubscribe();
    }
  }

  // =============================================================
  // Private — Channel Setup
  // =============================================================

  void _subscribeToPosts() {
    final channel = _client.channel('community_posts_realtime');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'community_posts',
      callback: _handlePostPayload,
    ).subscribe();
  }

  void _subscribeToComments() {
    final channel = _client.channel('community_comments_realtime');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'community_comments',
      callback: (PostgresChangePayload payload) => _handleCommentPayload(payload, null),
    ).subscribe();
  }

  void _subscribeToLikes() {
    final channel = _client.channel('community_likes_realtime');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'community_post_likes',
      callback: _handleLikePayload,
    ).subscribe();
  }

  void _subscribeToBookmarks() {
    final channel = _client.channel('community_bookmarks_realtime');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'community_bookmarks',
      callback: _handleBookmarkPayload,
    ).subscribe();
  }

  // =============================================================
  // Payload Handlers
  // =============================================================

  void _handlePostPayload(PostgresChangePayload payload) {
    final changeType = _mapType(payload.eventType.name);

    try {
      if (payload.newRecord != null && changeType != RealtimeChangeType.delete) {
        final post = CommunityPost.fromMap({
          'id': payload.newRecord['id'],
          'user_id': payload.newRecord['user_id'],
          'category': payload.newRecord['category'],
          'title': payload.newRecord['title'],
          'content': payload.newRecord['content'],
          'images': payload.newRecord['images'],
          'like_count': payload.newRecord['like_count'],
          'comment_count': payload.newRecord['comment_count'],
          'bookmark_count': payload.newRecord['bookmark_count'],
          'report_count': payload.newRecord['report_count'],
          'created_at': payload.newRecord['created_at'],
          'updated_at': payload.newRecord['updated_at'],
        });
        _postChanges.add(RealtimePostChange(type: changeType, post: post));
      } else {
        _postChanges.add(RealtimePostChange(type: changeType, postId: payload.oldRecord['id'] as String?));
      }
    } catch (e) {
      debugPrint('Realtime post handler: $e');
    }
  }

  void _handleCommentPayload(PostgresChangePayload payload, String? postId) {
    final changeType = _mapType(payload.eventType.name);

    try {
      final record = changeType == RealtimeChangeType.delete ? payload.oldRecord : payload.newRecord;
      if (record == null) return;

      final cmp = record['created_at'] as String?;

      _commentChanges.add(RealtimeCommentChange(
        type: changeType,
        postId: postId ?? record['post_id'] as String?,
        commentId: record['id'] as String?,
        comment: changeType != RealtimeChangeType.delete ? CommunityComment(
          id: record['id'] as String? ?? '',
          postId: record['post_id'] as String? ?? '',
          userId: record['user_id'] as String? ?? '',
          content: record['content'] as String? ?? '',
          likeCount: record['like_count'] as int? ?? 0,
          createdAt: cmp != null ? DateTime.parse(cmp) : DateTime.now(),
        ) : null,
      ));
    } catch (e) {
      debugPrint('Realtime comment handler: $e');
    }
  }

  void _handleLikePayload(PostgresChangePayload payload) {
    final postId = (payload.newRecord ?? payload.oldRecord)['post_id'] as String?;
    if (postId == null) return;
    _likeChanges.add(RealtimeLikeChange(postId: postId, newCount: -1));
  }

  void _handleBookmarkPayload(PostgresChangePayload payload) {
    final postId = (payload.newRecord ?? payload.oldRecord)['post_id'] as String?;
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
    _postChanges.close();
    _commentChanges.close();
    _likeChanges.close();
    _bookmarkChanges.close();
    _connectionState.dispose();
  }
}
