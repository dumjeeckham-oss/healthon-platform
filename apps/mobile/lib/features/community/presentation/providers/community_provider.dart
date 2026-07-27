import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/community_repository.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';

/// ===============================================================
/// Repository
/// ===============================================================

final communityRepositoryProvider =
    Provider<CommunityRepository>(
  (ref) => CommunityRepository(),
);

/// ===============================================================
/// 게시글 목록
/// ===============================================================

final communityPostsProvider =
    FutureProvider<List<CommunityPost>>(
  (ref) async {
    final repository =
        ref.watch(communityRepositoryProvider);

    return repository.loadPosts();
  },
);

/// ===============================================================
/// 카테고리별 게시글
/// ===============================================================

final communityCategoryProvider =
    FutureProvider.family<
        List<CommunityPost>,
        CommunityCategory>(
  (ref, category) async {
    final repository =
        ref.watch(communityRepositoryProvider);

    return repository.loadPosts(
      category: category,
    );
  },
);

/// ===============================================================
/// 게시글 상세
/// ===============================================================

final communityPostProvider =
    FutureProvider.family<
        CommunityPost,
        String>(
  (ref, postId) async {
    final repository =
        ref.watch(communityRepositoryProvider);

    return repository.getPost(postId);
  },
);

/// ===============================================================
/// 댓글 목록
/// ===============================================================

final communityCommentsProvider =
    FutureProvider.family<
        List<CommunityComment>,
        String>(
  (ref, postId) async {
    final repository =
        ref.watch(communityRepositoryProvider);

    return repository.loadComments(postId);
  },
);

/// ===============================================================
/// 게시글 작성
/// ===============================================================

final createPostProvider =
    FutureProvider.family<void, CommunityPost>(
  (ref, post) async {
    final repository =
        ref.read(communityRepositoryProvider);

    await repository.createPost(post);

    ref.invalidate(
      communityPostsProvider,
    );
  },
);

/// ===============================================================
/// 댓글 작성
/// ===============================================================

final addCommentProvider =
    FutureProvider.family<
        void,
        CommunityComment>(
  (ref, comment) async {
    final repository =
        ref.read(communityRepositoryProvider);

    await repository.addComment(comment);

    ref.invalidate(
      communityCommentsProvider(
        comment.postId,
      ),
    );

    ref.invalidate(
      communityPostsProvider,
    );
  },
);

/// ===============================================================
/// 좋아요
/// ===============================================================

final likePostProvider =
    FutureProvider.family<
        void,
        ({
          String userId,
          String postId,
        })>(
  (ref, params) async {
    final repository =
        ref.read(communityRepositoryProvider);

    await repository.likePost(
      userId: params.userId,
      postId: params.postId,
    );

    ref.invalidate(
      communityPostsProvider,
    );

    ref.invalidate(
      communityPostProvider(
        params.postId,
      ),
    );
  },
);

/// ===============================================================
/// 좋아요 취소
/// ===============================================================

final unlikePostProvider =
    FutureProvider.family<
        void,
        ({
          String userId,
          String postId,
        })>(
  (ref, params) async {
    final repository =
        ref.read(communityRepositoryProvider);

    await repository.unlikePost(
      userId: params.userId,
      postId: params.postId,
    );

    ref.invalidate(
      communityPostsProvider,
    );

    ref.invalidate(
      communityPostProvider(
        params.postId,
      ),
    );
  },
);

/// ===============================================================
/// 북마크
/// ===============================================================

final bookmarkProvider =
    FutureProvider.family<
        void,
        ({
          String userId,
          String postId,
        })>(
  (ref, params) async {
    final repository =
        ref.read(communityRepositoryProvider);

    await repository.bookmark(
      userId: params.userId,
      postId: params.postId,
    );
  },
);

/// ===============================================================
/// 북마크 취소
/// ===============================================================

final unBookmarkProvider =
    FutureProvider.family<
        void,
        ({
          String userId,
          String postId,
        })>(
  (ref, params) async {
    final repository =
        ref.read(communityRepositoryProvider);

    await repository.unBookmark(
      userId: params.userId,
      postId: params.postId,
    );
  },
);
