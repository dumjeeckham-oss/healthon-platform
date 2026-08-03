import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/community_post.dart';
import '../domain/models/community_comment.dart';
import '../presentation/providers/community_provider.dart';
import 'community_mapper.dart';

/// ===============================================================
///
/// HealthON Supabase Community Repository
///
/// ICommunityRepository 의 Supabase 구현체입니다.
///
/// 모든 예외는 CommunityRepositoryException 으로 래핑합니다.
///
/// ===============================================================

class SupabaseCommunityRepository implements ICommunityRepository {
  SupabaseCommunityRepository(this._client);

  final SupabaseClient _client;

  // =============================================================
  // Table / Bucket Constants
  // =============================================================

  static const String _postTable = 'community_posts';
  static const String _commentTable = 'community_comments';
  static const String _likeTable = 'community_post_likes';
  static const String _bookmarkTable = 'community_bookmarks';
  static const String _commentLikeTable = 'community_comment_likes';
  static const String _reportTable = 'community_reports';
  static const String _imageBucket = 'community-images';

  // =============================================================
  // 게시글 목록
  // =============================================================

  @override
  Future<List<CommunityPost>> loadPosts({
    CommunityCategory? category,
    int limit = 30,
  }) async {
    try {
      PostgrestFilterBuilder query = _client
          .from(_postTable)
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      if (category != null) {
        query = query.eq('category', category.name);
      }

      final List<dynamic> rows = await query;

      return rows
          .map((e) => CommunityPostSupabaseMapper.fromSupabase(
                e as Map<String, dynamic>,
              ))
          .toList();
    } catch (e, st) {
      throw CommunityRepositoryException(
        '게시글 목록 조회 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 게시글 상세
  // =============================================================

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

  // =============================================================
  // 게시글 생성
  // =============================================================

  @override
  Future<void> createPost(CommunityPost post) async {
    try {
      await _client.from(_postTable).insert(post.toSupabase());
    } catch (e, st) {
      throw CommunityRepositoryException(
        '게시글 생성 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 게시글 수정
  // =============================================================

  @override
  Future<void> updatePost(CommunityPost post) async {
    try {
      await _client
          .from(_postTable)
          .update(post.toSupabase())
          .eq('id', post.id);
    } catch (e, st) {
      throw CommunityRepositoryException(
        '게시글 수정 실패 (id=${post.id}): $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 게시글 삭제
  // =============================================================

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _client.from(_postTable).delete().eq('id', postId);
    } catch (e, st) {
      throw CommunityRepositoryException(
        '게시글 삭제 실패 (id=$postId): $e',
        cause: e,
        stackTrace: st,
      );
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
          .map((e) => CommunityCommentSupabaseMapper.fromSupabase(
                e as Map<String, dynamic>,
              ))
          .toList();
    } catch (e, st) {
      throw CommunityRepositoryException(
        '댓글 목록 조회 실패 (postId=$postId): $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 댓글 페이징 조회
  // =============================================================

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
          .map((e) => CommunityCommentSupabaseMapper.fromSupabase(
                e as Map<String, dynamic>,
              ))
          .toList();
    } catch (e, st) {
      throw CommunityRepositoryException(
        '댓글 페이징 조회 실패 (postId=$postId): $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 댓글 추가
  // =============================================================

  @override
  Future<void> addComment(CommunityComment comment) async {
    try {
      await _client.from(_commentTable).insert(comment.toSupabase());

      await _client.rpc('increment_comment_count', params: {
        'p_post_id': comment.postId,
      });
    } catch (e, st) {
      throw CommunityRepositoryException(
        '댓글 추가 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 댓글 수정
  // =============================================================

  @override
  Future<void> updateComment(CommunityComment comment) async {
    try {
      final Map<String, dynamic> data = {
        'content': comment.content,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      await _client
          .from(_commentTable)
          .update(data)
          .eq('id', comment.id);
    } catch (e, st) {
      throw CommunityRepositoryException(
        '댓글 수정 실패 (id=${comment.id}): $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 댓글 삭제
  // =============================================================

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      final Map<String, dynamic>? row = await _client
          .from(_commentTable)
          .select('post_id')
          .eq('id', commentId)
          .maybeSingle();

      final String? postId = row?['post_id']?.toString();

      await _client.from(_commentTable).delete().eq('id', commentId);

      if (postId != null && postId.isNotEmpty) {
        await _client.rpc('decrement_comment_count', params: {
          'p_post_id': postId,
        });
      }
    } catch (e, st) {
      throw CommunityRepositoryException(
        '댓글 삭제 실패 (id=$commentId): $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 게시글 좋아요
  // =============================================================

  @override
  Future<void> likePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final existing = await _client
          .from(_likeTable)
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      if (existing != null) return;

      await _client.from(_likeTable).insert({
        'user_id': userId,
        'post_id': postId,
      });

      await _client.rpc('increment_like_count', params: {
        'p_post_id': postId,
      });
    } catch (e, st) {
      throw CommunityRepositoryException(
        '좋아요 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> unlikePost({
    required String userId,
    required String postId,
  }) async {
    try {
      await _client
          .from(_likeTable)
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);

      await _client.rpc('decrement_like_count', params: {
        'p_post_id': postId,
      });
    } catch (e, st) {
      throw CommunityRepositoryException(
        '좋아요 취소 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 북마크
  // =============================================================

  @override
  Future<void> bookmark({
    required String userId,
    required String postId,
  }) async {
    try {
      final existing = await _client
          .from(_bookmarkTable)
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      if (existing != null) return;

      await _client.from(_bookmarkTable).insert({
        'user_id': userId,
        'post_id': postId,
      });

      await _client.rpc('increment_bookmark_count', params: {
        'p_post_id': postId,
      });
    } catch (e, st) {
      throw CommunityRepositoryException(
        '북마크 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> unBookmark({
    required String userId,
    required String postId,
  }) async {
    try {
      await _client
          .from(_bookmarkTable)
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);

      await _client.rpc('decrement_bookmark_count', params: {
        'p_post_id': postId,
      });
    } catch (e, st) {
      throw CommunityRepositoryException(
        '북마크 취소 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 댓글 좋아요 토글
  // =============================================================

  @override
  Future<void> toggleCommentLike({
    required String userId,
    required String commentId,
  }) async {
    try {
      final existing = await _client
          .from(_commentLikeTable)
          .select('id')
          .eq('user_id', userId)
          .eq('comment_id', commentId)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from(_commentLikeTable)
            .delete()
            .eq('user_id', userId)
            .eq('comment_id', commentId);

        await _client.rpc('decrement_comment_like_count', params: {
          'p_comment_id': commentId,
        });
      } else {
        await _client.from(_commentLikeTable).insert({
          'user_id': userId,
          'comment_id': commentId,
        });

        await _client.rpc('increment_comment_like_count', params: {
          'p_comment_id': commentId,
        });
      }
    } catch (e, st) {
      throw CommunityRepositoryException(
        '댓글 좋아요 토글 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> isCommentLiked(String userId, String commentId) async {
    try {
      final row = await _client
          .from(_commentLikeTable)
          .select('id')
          .eq('user_id', userId)
          .eq('comment_id', commentId)
          .maybeSingle();

      return row != null;
    } catch (e, st) {
      throw CommunityRepositoryException(
        '댓글 좋아요 상태 조회 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 게시글 좋아요 여부
  // =============================================================

  @override
  Future<bool> isPostLiked(String userId, String postId) async {
    try {
      final row = await _client
          .from(_likeTable)
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      return row != null;
    } catch (e, st) {
      throw CommunityRepositoryException(
        '좋아요 상태 조회 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> isBookmarked(String userId, String postId) async {
    try {
      final row = await _client
          .from(_bookmarkTable)
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      return row != null;
    } catch (e, st) {
      throw CommunityRepositoryException(
        '북마크 상태 조회 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // =============================================================
  // 신고
  // =============================================================

  @override
  Future<void> reportPost({
    required String reporterId,
    required String postId,
    required String reason,
  }) async {
    try {
      await _client.from(_reportTable).insert({
        'reporter_id': reporterId,
        'target_type': 'post',
        'target_id': postId,
        'reason': reason,
      });
    } catch (e, st) {
      throw CommunityRepositoryException(
        '게시글 신고 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> reportComment({
    required String reporterId,
    required String commentId,
    required String reason,
  }) async {
    try {
      await _client.from(_reportTable).insert({
        'reporter_id': reporterId,
        'target_type': 'comment',
        'target_id': commentId,
        'reason': reason,
      });
    } catch (e, st) {
      throw CommunityRepositoryException(
        '댓글 신고 실패: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
