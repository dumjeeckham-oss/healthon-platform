import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ===============================================================
///
/// HealthON Comment Like Provider
///
/// 각 댓글별 좋아요 상태를 관리하는 Riverpod StateNotifier 입니다.
///
/// ===============================================================

class CommentLikeState {
  final Set<String> likedIds;

  const CommentLikeState._(this.likedIds);

  factory CommentLikeState.initial() => const CommentLikeState._({});
}

class CommentLikeNotifier extends StateNotifier<CommentLikeState> {
  CommentLikeNotifier() : super(CommentLikeState.initial());

  bool isLiked(String commentId) => state.likedIds.contains(commentId);

  void toggle(String commentId) {
    final Set<String> next = Set<String>.from(state.likedIds);

    if (next.contains(commentId)) {
      next.remove(commentId);
    } else {
      next.add(commentId);
    }

    state = CommentLikeState._(next);
  }

  void setLiked(String commentId, bool liked) {
    final Set<String> next = Set<String>.from(state.likedIds);

    if (liked) {
      next.add(commentId);
    } else {
      next.remove(commentId);
    }

    state = CommentLikeState._(next);
  }
}

final commentLikeProvider =
    StateNotifierProvider<CommentLikeNotifier, CommentLikeState>(
  (ref) => CommentLikeNotifier(),
);
