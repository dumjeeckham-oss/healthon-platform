
/// ===============================================================
///
/// HealthON Community Comment
///
/// 댓글 / 대댓글
///
/// ===============================================================

library;

class CommunityComment {
  final String id;
  final String postId;
  final String userId;
  final String? parentId;
  final String content;
  final int likeCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// 멘션된 사용자 ID 목록
  final List<String> mentions;

  /// 첨부 이미지 URL 목록
  final List<String> images;

  /// GIF URL
  final String? gifUrl;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.content,
    this.likeCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.mentions = const [],
    this.images = const [],
    this.gifUrl,
  });

  factory CommunityComment.empty() {
    return CommunityComment(
      id: "",
      postId: "",
      userId: "",
      content: "",
      createdAt: DateTime.now(),
    );
  }

  bool get isRoot => parentId == null;
  bool get isReply => parentId != null;
  bool get isEdited => updatedAt != null;

  factory CommunityComment.fromMap(Map<String, dynamic> map) {
    return CommunityComment(
      id: map["id"] ?? "",
      postId: map["post_id"] ?? "",
      userId: map["user_id"] ?? "",
      parentId: map["parent_id"],
      content: map["content"] ?? "",
      likeCount: map["like_count"] ?? 0,
      createdAt: map["created_at"] != null ? DateTime.parse(map["created_at"]) : DateTime.now(),
      updatedAt: map["updated_at"] != null ? DateTime.parse(map["updated_at"]) : null,
      mentions: map["mentions"] != null ? List<String>.from(map["mentions"]) : const [],
      images: map["images"] != null ? List<String>.from(map["images"]) : const [],
      gifUrl: map["gif_url"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "post_id": postId,
      "user_id": userId,
      "parent_id": parentId,
      "content": content,
      "like_count": likeCount,
      "created_at": createdAt.toIso8601String(),
      if (updatedAt != null) "updated_at": updatedAt!.toIso8601String(),
      "mentions": mentions,
      "images": images,
      "gif_url": gifUrl,
    };
  }

  CommunityComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? parentId,
    String? content,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? mentions,
    List<String>? images,
    String? gifUrl,
  }) {
    return CommunityComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mentions: mentions ?? this.mentions,
      images: images ?? this.images,
      gifUrl: gifUrl ?? this.gifUrl,
    );
  }
}

// ===============================================================
// Comment Sort Type
// ===============================================================

enum CommentSortType {
  latest('최신순'),
  oldest('오래된순'),
  mostLiked('좋아요순');

  const CommentSortType(this.label);
  final String label;
}
