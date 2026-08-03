import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/community_repository.dart';
import '../../data/community_mapper.dart';
import '../../data/supabase_community_repository.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';

// ===============================================================
// Community Repository Exception
// ===============================================================

class CommunityRepositoryException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const CommunityRepositoryException(
    this.message, {
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() => 'CommunityRepositoryException: $message';
}

// ===============================================================
// Community Repository Interface
// ===============================================================

abstract class ICommunityRepository {
  Future<List<CommunityPost>> loadPosts({CommunityCategory? category, int limit});

  Future<CommunityPost> getPost(String postId);

  Future<void> createPost(CommunityPost post);

  Future<void> updatePost(CommunityPost post);

  Future<void> deletePost(String postId);

  Future<List<CommunityComment>> loadComments(String postId, {CommentSortType sort = CommentSortType.oldest});

  Future<List<CommunityComment>> loadCommentsPaged(String postId, {CommentSortType sort = CommentSortType.oldest, int offset = 0, int limit = 20});

  Future<void> addComment(CommunityComment comment);

  Future<void> updateComment(CommunityComment comment);

  Future<void> deleteComment(String commentId);

  Future<void> likePost({required String userId, required String postId});

  Future<void> unlikePost({required String userId, required String postId});

  Future<void> bookmark({required String userId, required String postId});

  Future<void> unBookmark({required String userId, required String postId});

  Future<bool> isPostLiked(String userId, String postId);

  Future<bool> isBookmarked(String userId, String postId);

  Future<void> toggleCommentLike({required String userId, required String commentId});

  Future<bool> isCommentLiked(String userId, String commentId);

  Future<void> reportPost({required String reporterId, required String postId, required String reason});

  Future<void> reportComment({required String reporterId, required String commentId, required String reason});
}

// ===============================================================
// Report Reason Constants
// ===============================================================

enum ReportReason {
  spam('스팸'),
  abusive('욕설'),
  advertising('광고'),
  inappropriate('음란물'),
  other('기타');

  const ReportReason(this.label);
  final String label;
}

// ===============================================================
// Mock Community Repository
// ===============================================================

class MockCommunityRepository implements ICommunityRepository {
  final List<CommunityPost> _posts = [];
  final Map<String, List<CommunityComment>> _comments = {};
  final Set<String> _likedPostIds = {};
  final Set<String> _bookmarkedPostIds = {};
  final Set<String> _likedCommentIds = {};

  /// 게시글 더미 데이터
  MockCommunityRepository() {
    _posts.addAll([
      CommunityPost(
        id: 'post-001',
        userId: 'user-001',
        category: CommunityCategory.forest,
        title: '오늘 나무가 쑥 자랐어요 🌱',
        content: 'Forest에서 3레벨을 달성했습니다! Pine Tree가 무럭무럭 자라고 있어요.',
        forestSnapshot: {'label': 'Pine Tree', 'level': 'Lv.3', 'growth': '72%'},
        walkingSnapshot: {'label': '오늘 걸음', 'steps': '12,345', 'distance': '8.2km'},
        badgeSnapshot: {'label': 'Forest Badge', 'level': 'Silver'},
        likeCount: 24,
        commentCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommunityPost(
        id: 'post-002',
        userId: 'user-002',
        category: CommunityCategory.walking,
        title: '오늘도 10,000보 달성!',
        content: '부천 둘레길을 걸었습니다. 날씨도 좋고 기분도 좋네요!',
        images: ['https://picsum.photos/seed/walk1/600/400'],
        walkingSnapshot: {'steps': '10,234', 'distance': '6.8km', 'calories': '420kcal', 'time': '1h 15m'},
        likeCount: 18,
        commentCount: 3,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CommunityPost(
        id: 'post-003',
        userId: 'user-003',
        category: CommunityCategory.challenge,
        title: '100K Challenge 도전중!',
        content: '벌써 42km 걸었습니다. 앞으로 58km 남았어요. 함께 걸어요!',
        badgeSnapshot: {'label': '100K Challenge', 'progress': '42%'},
        likeCount: 31,
        commentCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    _comments['post-001'] = [
      CommunityComment(
        id: 'cmt-001',
        postId: 'post-001',
        userId: 'user-002',
        content: '축하합니다! 🌱',
        likeCount: 3,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CommunityComment(
        id: 'cmt-002',
        postId: 'post-001',
        userId: 'user-003',
        content: '저도 Pine Tree 키우고 있어요!',
        likeCount: 1,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      CommunityComment(
        id: 'cmt-003',
        postId: 'post-001',
        userId: 'user-001',
        parentId: 'cmt-001',
        content: '감사합니다! 😊',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    _comments['post-002'] = [
      CommunityComment(
        id: 'cmt-004',
        postId: 'post-002',
        userId: 'user-001',
        content: '대단하세요!',
        likeCount: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];

    _comments['post-003'] = [];
  }

  @override
  Future<List<CommunityPost>> loadPosts({
    CommunityCategory? category,
    int limit = 30,
  }) async {
    try {
      List<CommunityPost> result = List<CommunityPost>.from(_posts);
      if (category != null) {
        result = result.where((p) => p.category == category).toList();
      }
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (result.length > limit) result = result.sublist(0, limit);
      return result;
    } catch (e) { rethrow; }
  }

  @override
  Future<CommunityPost> getPost(String postId) async {
    try {
      return _posts.firstWhere((p) => p.id == postId, orElse: () => CommunityPost.empty());
    } catch (e) { rethrow; }
  }

  @override
  Future<void> createPost(CommunityPost post) async {
    try { _posts.insert(0, post); _comments[post.id] = []; } catch (e) { rethrow; }
  }

  @override
  Future<void> updatePost(CommunityPost post) async {
    try {
      final idx = _posts.indexWhere((p) => p.id == post.id);
      if (idx != -1) _posts[idx] = post;
    } catch (e) { rethrow; }
  }

  @override
  Future<void> deletePost(String postId) async {
    try { _posts.removeWhere((p) => p.id == postId); _comments.remove(postId); } catch (e) { rethrow; }
  }

  @override
  Future<List<CommunityComment>> loadComments(String postId, {CommentSortType sort = CommentSortType.oldest}) async {
    try {
      final List<CommunityComment> list = List<CommunityComment>.from(_comments[postId] ?? []);
      switch (sort) {
        case CommentSortType.latest: list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); break;
        case CommentSortType.oldest: list.sort((a, b) => a.createdAt.compareTo(b.createdAt)); break;
        case CommentSortType.mostLiked: list.sort((a, b) => b.likeCount.compareTo(a.likeCount)); break;
      }
      return list;
    } catch (e) { rethrow; }
  }

  @override
  Future<List<CommunityComment>> loadCommentsPaged(String postId, {CommentSortType sort = CommentSortType.oldest, int offset = 0, int limit = 20}) async {
    final all = await loadComments(postId, sort: sort);
    if (offset >= all.length) return [];
    return all.skip(offset).take(limit).toList();
  }

  @override
  Future<void> addComment(CommunityComment comment) async {
    try {
      _comments.putIfAbsent(comment.postId, () => []);
      _comments[comment.postId]!.add(comment);
      final pi = _posts.indexWhere((p) => p.id == comment.postId);
      if (pi != -1) _posts[pi] = _posts[pi].copyWith(commentCount: _posts[pi].commentCount + 1);
    } catch (e) { rethrow; }
  }

  @override
  Future<void> updateComment(CommunityComment comment) async {
    try {
      for (final entry in _comments.entries) {
        final idx = entry.value.indexWhere((c) => c.id == comment.id);
        if (idx != -1) {
          entry.value[idx] = entry.value[idx].copyWith(content: comment.content, updatedAt: DateTime.now());
          break;
        }
      }
    } catch (e) { rethrow; }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      String? postId;
      for (final entry in _comments.entries) {
        final idx = entry.value.indexWhere((c) => c.id == commentId);
        if (idx != -1) { postId = entry.key; entry.value.removeAt(idx); break; }
      }
      if (postId != null) {
        final pi = _posts.indexWhere((p) => p.id == postId);
        if (pi != -1) _posts[pi] = _posts[pi].copyWith(commentCount: (_posts[pi].commentCount - 1).clamp(0, 999999));
      }
    } catch (e) { rethrow; }
  }

  @override
  Future<void> likePost({required String userId, required String postId}) async {
    try {
      _likedPostIds.add('${userId}_$postId');
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) _posts[idx] = _posts[idx].copyWith(likeCount: _posts[idx].likeCount + 1);
    } catch (e) { rethrow; }
  }

  @override
  Future<void> unlikePost({required String userId, required String postId}) async {
    try {
      final k = '${userId}_$postId';
      if (_likedPostIds.contains(k)) {
        _likedPostIds.remove(k);
        final idx = _posts.indexWhere((p) => p.id == postId);
        if (idx != -1) _posts[idx] = _posts[idx].copyWith(likeCount: (_posts[idx].likeCount - 1).clamp(0, 999999));
      }
    } catch (e) { rethrow; }
  }

  @override
  Future<bool> isPostLiked(String userId, String postId) async => _likedPostIds.contains('${userId}_$postId');

  @override
  Future<void> bookmark({required String userId, required String postId}) async {
    try {
      _bookmarkedPostIds.add('${userId}_$postId');
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) _posts[idx] = _posts[idx].copyWith(bookmarkCount: _posts[idx].bookmarkCount + 1);
    } catch (e) { rethrow; }
  }

  @override
  Future<void> unBookmark({required String userId, required String postId}) async {
    try {
      final k = '${userId}_$postId';
      if (_bookmarkedPostIds.contains(k)) {
        _bookmarkedPostIds.remove(k);
        final idx = _posts.indexWhere((p) => p.id == postId);
        if (idx != -1) _posts[idx] = _posts[idx].copyWith(bookmarkCount: (_posts[idx].bookmarkCount - 1).clamp(0, 999999));
      }
    } catch (e) { rethrow; }
  }

  @override
  Future<bool> isBookmarked(String userId, String postId) async => _bookmarkedPostIds.contains('${userId}_$postId');

  @override
  Future<void> toggleCommentLike({required String userId, required String commentId}) async {
    try {
      final k = '${userId}_$commentId';
      if (_likedCommentIds.contains(k)) {
        _likedCommentIds.remove(k);
      } else {
        _likedCommentIds.add(k);
      }
    } catch (e) { rethrow; }
  }

  @override
  Future<bool> isCommentLiked(String userId, String commentId) async => _likedCommentIds.contains('${userId}_$commentId');

  @override
  Future<void> reportPost({required String reporterId, required String postId, required String reason}) async {}
  @override
  Future<void> reportComment({required String reporterId, required String commentId, required String reason}) async {}
}

// ===============================================================
// Supabase Client Provider
// ===============================================================

final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ===============================================================
// Repository Provider (Production)
// ===============================================================

final communityRepositoryProvider = Provider<ICommunityRepository>(
  (ref) => SupabaseCommunityRepository(ref.watch(supabaseProvider)),
);

// ===============================================================
// Mock Repository Provider (Debug / Development)
// ===============================================================

final debugMockCommunityRepositoryProvider = Provider<ICommunityRepository>(
  (ref) => MockCommunityRepository(),
);

// ===============================================================
// 정렬 상태 Provider
// ===============================================================

final commentSortProvider = StateProvider<CommentSortType>(
  (ref) => CommentSortType.oldest,
);

// ===============================================================
// 게시글 목록
// ===============================================================

final communityPostsProvider = FutureProvider<List<CommunityPost>>((ref) async {
  try {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.loadPosts();
  } catch (e) { rethrow; }
});

// ===============================================================
// 카테고리별 게시글
// ===============================================================

final communityCategoryProvider = FutureProvider.family<List<CommunityPost>, CommunityCategory>((ref, cat) async {
  try {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.loadPosts(category: cat);
  } catch (e) { rethrow; }
});

// ===============================================================
// 게시글 상세
// ===============================================================

final communityPostProvider = FutureProvider.family<CommunityPost, String>((ref, postId) async {
  try {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.getPost(postId);
  } catch (e) { rethrow; }
});

// ===============================================================
// 댓글 목록 (정렬 지원)
// ===============================================================

final communityCommentsProvider = FutureProvider.family<List<CommunityComment>, String>((ref, postId) async {
  try {
    final repo = ref.watch(communityRepositoryProvider);
    final sort = ref.watch(commentSortProvider);
    return repo.loadComments(postId, sort: sort);
  } catch (e) { rethrow; }
});

// ===============================================================
// 게시글 작성
// ===============================================================

final createPostProvider = FutureProvider.family<void, CommunityPost>((ref, post) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.createPost(post);
    ref.invalidate(communityPostsProvider);
  } catch (e) { rethrow; }
});

// ===============================================================
// 댓글 작성
// ===============================================================

final addCommentProvider = FutureProvider.family<void, CommunityComment>((ref, comment) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.addComment(comment);
    ref.invalidate(communityCommentsProvider(comment.postId));
    ref.invalidate(communityPostsProvider);
  } catch (e) { rethrow; }
});

// ===============================================================
// 댓글 수정
// ===============================================================

final updateCommentProvider = FutureProvider.family<void, CommunityComment>((ref, comment) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.updateComment(comment);
    ref.invalidate(communityCommentsProvider(comment.postId));
  } catch (e) { rethrow; }
});

// ===============================================================
// 댓글 삭제
// ===============================================================

final deleteCommentProvider = FutureProvider.family<void, ({String postId, String commentId})>((ref, params) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.deleteComment(params.commentId);
    ref.invalidate(communityCommentsProvider(params.postId));
    ref.invalidate(communityPostsProvider);
  } catch (e) { rethrow; }
});

// ===============================================================
// 댓글 좋아요 토글
// ===============================================================

final toggleCommentLikeProvider = FutureProvider.family<void, ({String userId, String commentId, String postId})>((ref, params) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.toggleCommentLike(userId: params.userId, commentId: params.commentId);
    ref.invalidate(communityCommentsProvider(params.postId));
  } catch (e) { rethrow; }
});

// ===============================================================
// 게시글 좋아요 토글 (Optimistic)
// ===============================================================

final togglePostLikeProvider = FutureProvider.family<void, String>((ref, postId) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    final String uid = Supabase.instance.client.auth.currentUser?.id ?? 'current_user';
    final bool liked = await repo.isPostLiked(uid, postId);
    if (liked) {
      await repo.unlikePost(userId: uid, postId: postId);
    } else {
      await repo.likePost(userId: uid, postId: postId);
    }
    ref.invalidate(communityPostProvider(postId));
    ref.invalidate(communityPostsProvider);
  } catch (e) { rethrow; }
});

// ===============================================================
// 북마크 토글 (Optimistic)
// ===============================================================

final toggleBookmarkProvider = FutureProvider.family<void, String>((ref, postId) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    final String uid = Supabase.instance.client.auth.currentUser?.id ?? 'current_user';
    final bool bookmarked = await repo.isBookmarked(uid, postId);
    if (bookmarked) {
      await repo.unBookmark(userId: uid, postId: postId);
    } else {
      await repo.bookmark(userId: uid, postId: postId);
    }
    ref.invalidate(communityPostProvider(postId));
    ref.invalidate(communityPostsProvider);
  } catch (e) { rethrow; }
});

// ===============================================================
// 게시글 신고
// ===============================================================

final reportPostProvider = FutureProvider.family<void, ({String reporterId, String postId, String reason})>((ref, p) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.reportPost(reporterId: p.reporterId, postId: p.postId, reason: p.reason);
  } catch (e) { rethrow; }
});

// ===============================================================
// 댓글 신고
// ===============================================================

final reportCommentProvider = FutureProvider.family<void, ({String reporterId, String commentId, String reason})>((ref, p) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.reportComment(reporterId: p.reporterId, commentId: p.commentId, reason: p.reason);
  } catch (e) { rethrow; }
});

// ===============================================================
// 게시글 새로고침
// ===============================================================

final refreshCommunityPostProvider = FutureProvider.family<void, String>((ref, postId) async {
  ref.invalidate(communityPostProvider(postId));
});

// ===============================================================
// 댓글 새로고침
// ===============================================================

final refreshCommentsProvider = FutureProvider.family<void, String>((ref, postId) async {
  ref.invalidate(communityCommentsProvider(postId));
});

// ===============================================================
// 좋아요 (기존)
// ===============================================================

final likePostProvider = FutureProvider.family<void, ({String userId, String postId})>((ref, p) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.likePost(userId: p.userId, postId: p.postId);
    ref.invalidate(communityPostsProvider);
    ref.invalidate(communityPostProvider(p.postId));
  } catch (e) { rethrow; }
});

// ===============================================================
// 좋아요 취소 (기존)
// ===============================================================

final unlikePostProvider = FutureProvider.family<void, ({String userId, String postId})>((ref, p) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.unlikePost(userId: p.userId, postId: p.postId);
    ref.invalidate(communityPostsProvider);
    ref.invalidate(communityPostProvider(p.postId));
  } catch (e) { rethrow; }
});

// ===============================================================
// 북마크 (기존)
// ===============================================================

final bookmarkProvider = FutureProvider.family<void, ({String userId, String postId})>((ref, p) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.bookmark(userId: p.userId, postId: p.postId);
  } catch (e) { rethrow; }
});

// ===============================================================
// 북마크 취소 (기존)
// ===============================================================

final unBookmarkProvider = FutureProvider.family<void, ({String userId, String postId})>((ref, p) async {
  try {
    final repo = ref.read(communityRepositoryProvider);
    await repo.unBookmark(userId: p.userId, postId: p.postId);
  } catch (e) { rethrow; }
});
