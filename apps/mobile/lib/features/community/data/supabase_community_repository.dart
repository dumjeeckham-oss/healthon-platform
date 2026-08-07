import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/platform/file_bytes_stub.dart'
  if (dart.library.io) '../../../core/platform/file_bytes_io.dart'
  if (dart.library.html) '../../../core/platform/file_bytes_web.dart';

import '../domain/models/community_post.dart';
import '../domain/models/community_comment.dart';
import '../presentation/providers/community_provider.dart';
import 'community_mapper.dart';

/// HealthON Supabase Community Repository
///
/// ICommunityRepository 의 Supabase 구현체입니다.
class SupabaseCommunityRepository implements ICommunityRepository {
  SupabaseCommunityRepository(this._client);

  final SupabaseClient _client;

  static const String _postTable = 'community_posts';
  static const String _commentTable = 'community_comments';
  static const String _likeTable = 'community_post_likes';
  static const String _bookmarkTable = 'community_bookmarks';
  static const String _commentLikeTable = 'community_comment_likes';
  static const String _reportTable = 'community_reports';
  static const String _commentImageBucket = 'community-comment-images';

  // =============================================================
  // 게시글 목록
  // =============================================================

  @override
  Future<List<CommunityPost>> loadPosts({
    CommunityCategory? category,
    int limit = 30,
  }) async {
    try {
      if (category != null) {
        final rows = await _client.from(_postTable)
            .select()
            .eq('category', category.name)
            .order('created_at', ascending: false)
            .limit(limit);

        final List<dynamic> typedRows = rows;
        return typedRows
            .map((e) => CommunityPostSupabaseMapper.fromSupabase(
                  e as Map<String, dynamic>,
                ))
            .toList();
      } else {
        final rows = await _client.from(_postTable)
            .select()
            .order('created_at', ascending: false)
            .limit(limit);

        final List<dynamic> typedRows = rows;
        return typedRows
            .map((e) => CommunityPostSupabaseMapper.fromSupabase(
                  e as Map<String, dynamic>,
                ))
            .toList();
      }
    } catch (e, st) {
      throw CommunityRepositoryException(
        '게시글 목록 조회 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<CommunityPost> getPost(String postId) async {
    try {
      final Map<String, dynamic> row = await _client
          .from(_postTable)
          .select()
          .eq('id', postId)
          .single();

      return CommunityPostSupabaseMapper.fromSupabase(row);
    } catch (e, st) {
      throw CommunityRepositoryException(
        '게시글 상세 조회 실패 (id=$postId): $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> createPost(CommunityPost post) async {
    try {
      await _client.from(_postTable).insert(post.toSupabase());
    } catch (e, st) {
      throw CommunityRepositoryException('게시글 생성 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> updatePost(CommunityPost post) async {
    try {
      await _client.from(_postTable).update(post.toSupabase()).eq('id', post.id);
    } catch (e, st) {
      throw CommunityRepositoryException('게시글 수정 실패 (id=${post.id}): $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _client.from(_postTable).delete().eq('id', postId);
    } catch (e, st) {
      throw CommunityRepositoryException('게시글 삭제 실패 (id=$postId): $e', cause: e, stackTrace: st);
    }
  }

  // =============================================================
  // 댓글 목록 (정렬 지원)
  // =============================================================

  @override
  Future<List<CommunityComment>> loadComments(
    String postId, {
    CommentSortType sort = CommentSortType.oldest,
  }) async {
    try {
      String orderColumn;
      bool ascending;

      switch (sort) {
        case CommentSortType.latest:
          orderColumn = 'created_at';
          ascending = false;
          break;
        case CommentSortType.oldest:
          orderColumn = 'created_at';
          ascending = true;
          break;
        case CommentSortType.mostLiked:
          orderColumn = 'like_count';
          ascending = false;
          break;
      }

      final List<dynamic> rows = await _client
          .from(_commentTable)
          .select()
          .eq('post_id', postId)
          .order(orderColumn, ascending: ascending);

      return rows
          .map((e) => CommunityCommentSupabaseMapper.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      throw CommunityRepositoryException('댓글 목록 조회 실패 (postId=$postId): $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<List<CommunityComment>> loadCommentsPaged(
    String postId, {
    CommentSortType sort = CommentSortType.oldest,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      String orderColumn;
      bool ascending;

      switch (sort) {
        case CommentSortType.latest:
          orderColumn = 'created_at';
          ascending = false;
          break;
        case CommentSortType.oldest:
          orderColumn = 'created_at';
          ascending = true;
          break;
        case CommentSortType.mostLiked:
          orderColumn = 'like_count';
          ascending = false;
          break;
      }

      final List<dynamic> rows = await _client
          .from(_commentTable)
          .select()
          .eq('post_id', postId)
          .order(orderColumn, ascending: ascending)
          .range(offset, offset + limit - 1);

      return rows
          .map((e) => CommunityCommentSupabaseMapper.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      throw CommunityRepositoryException('댓글 페이징 조회 실패 (postId=$postId): $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> addComment(CommunityComment comment) async {
    try {
      await _client.from(_commentTable).insert(comment.toSupabase());
      await _client.rpc('increment_comment_count', params: {'p_post_id': comment.postId});
    } catch (e, st) {
      throw CommunityRepositoryException('댓글 추가 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> updateComment(CommunityComment comment) async {
    try {
      final data = {
        'content': comment.content,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      await _client.from(_commentTable).update(data).eq('id', comment.id);
    } catch (e, st) {
      throw CommunityRepositoryException('댓글 수정 실패 (id=${comment.id}): $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      final row = await _client.from(_commentTable).select('post_id').eq('id', commentId).maybeSingle();
      final String? postId = row?['post_id']?.toString();
      await _client.from(_commentTable).delete().eq('id', commentId);
      if (postId != null && postId.isNotEmpty) {
        await _client.rpc('decrement_comment_count', params: {'p_post_id': postId});
      }
    } catch (e, st) {
      throw CommunityRepositoryException('댓글 삭제 실패 (id=$commentId): $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> likePost({required String userId, required String postId}) async {
    try {
      final existing = await _client.from(_likeTable).select('id').eq('user_id', userId).eq('post_id', postId).maybeSingle();
      if (existing != null) return;
      await _client.from(_likeTable).insert({'user_id': userId, 'post_id': postId});
      await _client.rpc('increment_like_count', params: {'p_post_id': postId});
    } catch (e, st) {
      throw CommunityRepositoryException('좋아요 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> unlikePost({required String userId, required String postId}) async {
    try {
      await _client.from(_likeTable).delete().eq('user_id', userId).eq('post_id', postId);
      await _client.rpc('decrement_like_count', params: {'p_post_id': postId});
    } catch (e, st) {
      throw CommunityRepositoryException('좋아요 취소 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> bookmark({required String userId, required String postId}) async {
    try {
      final existing = await _client.from(_bookmarkTable).select('id').eq('user_id', userId).eq('post_id', postId).maybeSingle();
      if (existing != null) return;
      await _client.from(_bookmarkTable).insert({'user_id': userId, 'post_id': postId});
      await _client.rpc('increment_bookmark_count', params: {'p_post_id': postId});
    } catch (e, st) {
      throw CommunityRepositoryException('북마크 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> unBookmark({required String userId, required String postId}) async {
    try {
      await _client.from(_bookmarkTable).delete().eq('user_id', userId).eq('post_id', postId);
      await _client.rpc('decrement_bookmark_count', params: {'p_post_id': postId});
    } catch (e, st) {
      throw CommunityRepositoryException('북마크 취소 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> toggleCommentLike({required String userId, required String commentId}) async {
    try {
      final existing = await _client.from(_commentLikeTable).select('id').eq('user_id', userId).eq('comment_id', commentId).maybeSingle();
      if (existing != null) {
        await _client.from(_commentLikeTable).delete().eq('user_id', userId).eq('comment_id', commentId);
        await _client.rpc('decrement_comment_like_count', params: {'p_comment_id': commentId});
      } else {
        await _client.from(_commentLikeTable).insert({'user_id': userId, 'comment_id': commentId});
        await _client.rpc('increment_comment_like_count', params: {'p_comment_id': commentId});
      }
    } catch (e, st) {
      throw CommunityRepositoryException('댓글 좋아요 토글 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<bool> isCommentLiked(String userId, String commentId) async {
    try {
      final row = await _client.from(_commentLikeTable).select('id').eq('user_id', userId).eq('comment_id', commentId).maybeSingle();
      return row != null;
    } catch (e, st) {
      throw CommunityRepositoryException('댓글 좋아요 상태 조회 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<bool> isPostLiked(String userId, String postId) async {
    try {
      final row = await _client.from(_likeTable).select('id').eq('user_id', userId).eq('post_id', postId).maybeSingle();
      return row != null;
    } catch (e, st) {
      throw CommunityRepositoryException('좋아요 상태 조회 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<bool> isBookmarked(String userId, String postId) async {
    try {
      final row = await _client.from(_bookmarkTable).select('id').eq('user_id', userId).eq('post_id', postId).maybeSingle();
      return row != null;
    } catch (e, st) {
      throw CommunityRepositoryException('북마크 상태 조회 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> reportPost({required String reporterId, required String postId, required String reason}) async {
    try {
      await _client.from(_reportTable).insert({'reporter_id': reporterId, 'target_type': 'post', 'target_id': postId, 'reason': reason});
    } catch (e, st) {
      throw CommunityRepositoryException('게시글 신고 실패: $e', cause: e, stackTrace: st);
    }
  }

  @override
  Future<void> reportComment({required String reporterId, required String commentId, required String reason}) async {
    try {
      await _client.from(_reportTable).insert({'reporter_id': reporterId, 'target_type': 'comment', 'target_id': commentId, 'reason': reason});
    } catch (e, st) {
      throw CommunityRepositoryException('댓글 신고 실패: $e', cause: e, stackTrace: st);
    }
  }

  // =============================================================
  // 신규: @멘션 사용자 검색
  // =============================================================

  @override
  Future<List<({String id, String name})>> mentionUser(String query) async {
    try {
      final List<dynamic> rows = await _client
          .from('profiles')
          .select('id, name')
          .ilike('name', '%$query%')
          .limit(10);
      return rows.map((e) => (id: e['id'] as String, name: e['name'] as String)).toList();
    } catch (e, st) {
      throw CommunityRepositoryException('멘션 사용자 검색 실패: $e', cause: e, stackTrace: st);
    }
  }

  // =============================================================
  // 신규: 댓글 이미지 업로드
  // =============================================================

  @override
  Future<List<String>> uploadCommentImages({required String postId, required List<String> localPaths}) async {
    try {
      final List<String> urls = [];
      for (final path in localPaths) {
        final fileName = '${postId}_${DateTime.now().millisecondsSinceEpoch}_${urls.length}.jpg';
        final bytes = await readFileBytes(path);
        await _client.storage.from(_commentImageBucket).uploadBinary(fileName, bytes);
        final publicUrl = _client.storage.from(_commentImageBucket).getPublicUrl(fileName);
        urls.add(publicUrl);
      }
      return urls;
    } catch (e, st) {
      throw CommunityRepositoryException('댓글 이미지 업로드 실패: $e', cause: e, stackTrace: st);
    }
  }

  // =============================================================
  // 신규: GIF 검색 (mock)
  // =============================================================

  @override
  Future<List<({String id, String url, String previewUrl, String title})>> searchGif(String query) async {
    const mockGifs = [
      (id: 'g1', url: 'https://media.giphy.com/media/v1.Y2lk/1.gif', previewUrl: 'https://media.giphy.com/media/v1.Y2lk/1_s.gif', title: '박수'),
      (id: 'g2', url: 'https://media.giphy.com/media/v1.Y2lk/2.gif', previewUrl: 'https://media.giphy.com/media/v1.Y2lk/2_s.gif', title: '웃음'),
      (id: 'g3', url: 'https://media.giphy.com/media/v1.Y2lk/3.gif', previewUrl: 'https://media.giphy.com/media/v1.Y2lk/3_s.gif', title: '축하'),
      (id: 'g4', url: 'https://media.giphy.com/media/v1.Y2lk/4.gif', previewUrl: 'https://media.giphy.com/media/v1.Y2lk/4_s.gif', title: '화이팅'),
    ];
    await Future.delayed(const Duration(milliseconds: 300));
    return mockGifs.where((g) => g.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // =============================================================
  // 신규: 멘션 / 답글 / 좋아요 알림 생성 (RPC 기반, 현행 schema)
  // =============================================================

  @override
  Future<void> createMentionNotification({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String commentId,
  }) async {
    try {
      await _client.rpc('create_mention_notification', params: {
        'p_user_id': toUserId,
        'p_from_user_id': fromUserId,
        'p_post_id': postId,
        'p_comment_id': commentId,
      });
    } catch (e, st) {
      throw CommunityRepositoryException('멘션 알림 생성 실패: $e', cause: e, stackTrace: st);
    }
  }

  Future<void> createReplyNotification({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String commentId,
  }) async {
    try {
      await _client.rpc('create_reply_notification', params: {
        'p_user_id': toUserId,
        'p_from_user_id': fromUserId,
        'p_post_id': postId,
        'p_comment_id': commentId,
      });
    } catch (e, st) {
      throw CommunityRepositoryException('답글 알림 생성 실패: $e', cause: e, stackTrace: st);
    }
  }

  Future<void> createCommentLikeNotification({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String commentId,
  }) async {
    try {
      await _client.rpc('create_comment_like_notification', params: {
        'p_user_id': toUserId,
        'p_from_user_id': fromUserId,
        'p_post_id': postId,
        'p_comment_id': commentId,
      });
    } catch (e, st) {
      throw CommunityRepositoryException('댓글 좋아요 알림 생성 실패: $e', cause: e, stackTrace: st);
    }
  }
}
