import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ===============================================================
/// HealthON Comment Image Provider
///
/// 댓글 이미지 업로드
/// ===============================================================

class CommentImageState {
  final List<String> uploadedUrls;
  final bool isUploading;
  final String? error;

  const CommentImageState({
    this.uploadedUrls = const [],
    this.isUploading = false,
    this.error,
  });
}

class CommentImageNotifier extends StateNotifier<CommentImageState> {
  CommentImageNotifier() : super(const CommentImageState());

  void addLocal(String path) {
    state = CommentImageState(
      uploadedUrls: [...state.uploadedUrls, path],
    );
  }

  void removeAt(int index) {
    final list = List<String>.from(state.uploadedUrls);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
    }
    state = CommentImageState(uploadedUrls: list);
  }

  void clear() => state = const CommentImageState();

  /// Mock upload — Supabase Storage 연동으로 교체
  Future<void> uploadImages(List<String> paths, {required String postId}) async {
    state = CommentImageState(isUploading: true, uploadedUrls: state.uploadedUrls);

    // Simulate upload
    await Future.delayed(const Duration(seconds: 1));

    // Mock — 실제로는 Supabase Storage upload + getPublicUrl
    final urls = paths.map((p) => 'https://mock-storage/community-comment-images/$postId/${p.hashCode}.jpg').toList();

    state = CommentImageState(uploadedUrls: urls);
  }
}

final commentImageProvider =
    StateNotifierProvider<CommentImageNotifier, CommentImageState>(
  (ref) => CommentImageNotifier(),
);
