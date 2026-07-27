import 'package:flutter/foundation.dart';

/// ===============================================================
///
/// HealthON Community Comment
///
/// 댓글 / 대댓글
///
/// ===============================================================

class CommunityComment {
  final String id;

  /// 게시글 ID
  final String postId;

  /// 작성자
  final String userId;

  /// 부모 댓글
  /// null이면 댓글
  /// 값이 있으면 대댓글
  final String? parentId;

  /// 내용
  final String content;

  /// 좋아요 수
  final int likeCount;

  /// 작성시간
  final DateTime createdAt;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.content,
    this.likeCount = 0,
    required this.createdAt,
  });

  /// ===============================================================
  /// Empty
  /// ===============================================================

  factory CommunityComment.empty() {
    return CommunityComment(
      id: "",
      postId: "",
      userId: "",
      parentId: null,
      content: "",
      createdAt: DateTime.now(),
    );
  }

  /// ===============================================================
  /// 댓글인가?
  /// ===============================================================

  bool get isRoot => parentId == null;

  /// ===============================================================
  /// 대댓글인가?
  /// ===============================================================

  bool get isReply => parentId != null;

  /// ===============================================================
  /// Supabase -> Model
  /// ===============================================================

  factory CommunityComment.fromMap(
    Map<String, dynamic> map,
  ) {
    return CommunityComment(
      id: map["id"] ?? "",

      postId: map["post_id"] ?? "",

      userId: map["user_id"] ?? "",

      parentId: map["parent_id"],

      content: map["content"] ?? "",

      likeCount: map["like_count"] ?? 0,

      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : DateTime.now(),
    );
  }

  /// ===============================================================
  /// Model -> Supabase
  /// ===============================================================

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "post_id": postId,
      "user_id": userId,
      "parent_id": parentId,
      "content": content,
      "like_count": likeCount,
      "created_at": createdAt.toIso8601String(),
    };
  }

  /// ===============================================================
  /// copyWith
  /// ===============================================================

  CommunityComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? parentId,
    String? content,
    int? likeCount,
    DateTime? createdAt,
  }) {
    return CommunityComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return '''
CommunityComment(
  id: $id,
  postId: $postId,
  userId: $userId,
  parentId: $parentId,
  content: $content,
  likeCount: $likeCount,
)
''';
  }
}
