import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/community_post.dart';
import '../domain/models/community_comment.dart';

class CommunityRepository {
  CommunityRepository();

  final SupabaseClient _client = Supabase.instance.client;

  static const _postTable = "community_posts";
  static const _commentTable = "community_comments";
  static const _likeTable = "community_likes";
  static const _bookmarkTable = "community_bookmarks";

  //----------------------------------------------------------
  // 게시글 목록
  //----------------------------------------------------------

  Future<List<CommunityPost>> loadPosts({
    CommunityCategory? category,
    int limit = 30,
  }) async {
    dynamic query = _client
        .from(_postTable)
        .select()
        .order("created_at", ascending: false)
        .limit(limit);

    if (category != null) {
      query = query.eq(
        "category",
        category.name,
      );
    }

    final result = await query;

    return (result as List)
        .map((e) => CommunityPost.fromMap(e))
        .toList();
  }

  //----------------------------------------------------------
  // 게시글 상세
  //----------------------------------------------------------

  Future<CommunityPost> getPost(
    String postId,
  ) async {
    final result = await _client
        .from(_postTable)
        .select()
        .eq("id", postId)
        .single();

    return CommunityPost.fromMap(result);
  }

  //----------------------------------------------------------
  // 게시글 작성
  //----------------------------------------------------------

  Future<void> createPost(
    CommunityPost post,
  ) async {
    await _client
        .from(_postTable)
        .insert(post.toMap());
  }

  //----------------------------------------------------------
  // 게시글 수정
  //----------------------------------------------------------

  Future<void> updatePost(
    CommunityPost post,
  ) async {
    await _client
        .from(_postTable)
        .update(post.toMap())
        .eq("id", post.id);
  }

  //----------------------------------------------------------
  // 게시글 삭제
  //----------------------------------------------------------

  Future<void> deletePost(
    String postId,
  ) async {
    await _client
        .from(_postTable)
        .delete()
        .eq("id", postId);
  }

  //----------------------------------------------------------
  // 댓글 목록
  //----------------------------------------------------------

  Future<List<CommunityComment>> loadComments(
    String postId,
  ) async {
    final result = await _client
        .from(_commentTable)
        .select()
        .eq("post_id", postId)
        .order(
          "created_at",
          ascending: true,
        );

    return (result as List)
        .map((e) => CommunityComment.fromMap(e))
        .toList();
  }

  //----------------------------------------------------------
  // 댓글 작성
  //----------------------------------------------------------

  Future<void> addComment(
    CommunityComment comment,
  ) async {
    await _client
        .from(_commentTable)
        .insert(comment.toMap());

    await _client.rpc(
      "increase_comment_count",
      params: {
        "post_uuid": comment.postId,
      },
    );
  }

  //----------------------------------------------------------
  // 댓글 삭제
  //----------------------------------------------------------

  Future<void> deleteComment(
    String commentId,
  ) async {
    await _client
        .from(_commentTable)
        .delete()
        .eq("id", commentId);
  }

  //----------------------------------------------------------
  // 좋아요
  //----------------------------------------------------------

  Future<void> likePost({
    required String userId,
    required String postId,
    String emoji = "👍",
  }) async {
    await _client
        .from(_likeTable)
        .upsert({
      "user_id": userId,
      "post_id": postId,
      "emoji": emoji,
    });

    await _client.rpc(
      "increase_like_count",
      params: {
        "post_uuid": postId,
      },
    );
  }

  //----------------------------------------------------------
  // 좋아요 취소
  //----------------------------------------------------------

  Future<void> unlikePost({
    required String userId,
    required String postId,
  }) async {
    await _client
        .from(_likeTable)
        .delete()
        .eq("user_id", userId)
        .eq("post_id", postId);

    await _client.rpc(
      "decrease_like_count",
      params: {
        "post_uuid": postId,
      },
    );
  }

  //----------------------------------------------------------
  // 북마크
  //----------------------------------------------------------

  Future<void> bookmark({
    required String userId,
    required String postId,
  }) async {
    await _client
        .from(_bookmarkTable)
        .upsert({
      "user_id": userId,
      "post_id": postId,
    });
  }

  //----------------------------------------------------------
  // 북마크 취소
  //----------------------------------------------------------

  Future<void> unBookmark({
    required String userId,
    required String postId,
  }) async {
    await _client
        .from(_bookmarkTable)
        .delete()
        .eq("user_id", userId)
        .eq("post_id", postId);
  }
}
