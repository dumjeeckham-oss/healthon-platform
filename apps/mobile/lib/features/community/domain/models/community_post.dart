/// ===============================================================
///
/// HealthON Community Post
///
/// Forest
/// Walking
/// Challenge
/// Health
/// Free Board
///
/// ===============================================================

library;

enum CommunityCategory {
  notice,
  challenge,
  walking,
  forest,
  health,
  photo,
  free,
  question,
  event,
}

class CommunityPost {
  final String id;

  final String userId;

  final CommunityCategory category;

  final String title;

  final String content;

  final List<String> images;

  final String? videoUrl;

  /// Forest Snapshot
  final Map<String, dynamic>? forestSnapshot;

  /// Walking Snapshot
  final Map<String, dynamic>? walkingSnapshot;

  /// Badge Snapshot
  final Map<String, dynamic>? badgeSnapshot;

  final String? location;

  final double? latitude;

  final double? longitude;

  final String visibility;

  final int likeCount;

  final int commentCount;

  final int bookmarkCount;

  final int reportCount;

  final DateTime createdAt;

  final DateTime updatedAt;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.category,
    required this.title,
    required this.content,
    this.images = const [],
    this.videoUrl,
    this.forestSnapshot,
    this.walkingSnapshot,
    this.badgeSnapshot,
    this.location,
    this.latitude,
    this.longitude,
    this.visibility = "public",
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.reportCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ===============================================================
  /// Empty
  /// ===============================================================

  factory CommunityPost.empty() {
    return CommunityPost(
      id: "",
      userId: "",
      category: CommunityCategory.free,
      title: "",
      content: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// ===============================================================
  /// Supabase → Model
  /// ===============================================================

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map["id"] ?? "",
      userId: map["user_id"] ?? "",
      category: _categoryFromString(map["category"]),
      title: map["title"] ?? "",
      content: map["content"] ?? "",

      images: map["images"] != null
          ? List<String>.from(map["images"])
          : const [],

      videoUrl: map["video_url"],

      forestSnapshot: map["forest_snapshot"] != null
          ? Map<String, dynamic>.from(map["forest_snapshot"])
          : null,

      walkingSnapshot: map["walking_snapshot"] != null
          ? Map<String, dynamic>.from(map["walking_snapshot"])
          : null,

      badgeSnapshot: map["badge_snapshot"] != null
          ? Map<String, dynamic>.from(map["badge_snapshot"])
          : null,

      location: map["location"],

      latitude: map["latitude"] != null
          ? (map["latitude"] as num).toDouble()
          : null,

      longitude: map["longitude"] != null
          ? (map["longitude"] as num).toDouble()
          : null,

      visibility: map["visibility"] ?? "public",

      likeCount: map["like_count"] ?? 0,
      commentCount: map["comment_count"] ?? 0,
      bookmarkCount: map["bookmark_count"] ?? 0,
      reportCount: map["report_count"] ?? 0,

      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : DateTime.now(),

      updatedAt: map["updated_at"] != null
          ? DateTime.parse(map["updated_at"])
          : DateTime.now(),
    );
  }

  /// ===============================================================
  /// Model → Supabase
  /// ===============================================================

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "user_id": userId,
      "category": category.name,
      "title": title,
      "content": content,
      "images": images,
      "video_url": videoUrl,
      "forest_snapshot": forestSnapshot,
      "walking_snapshot": walkingSnapshot,
      "badge_snapshot": badgeSnapshot,
      "location": location,
      "latitude": latitude,
      "longitude": longitude,
      "visibility": visibility,
      "like_count": likeCount,
      "comment_count": commentCount,
      "bookmark_count": bookmarkCount,
      "report_count": reportCount,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }

  /// ===============================================================
  /// copyWith
  /// ===============================================================

  CommunityPost copyWith({
    String? id,
    String? userId,
    CommunityCategory? category,
    String? title,
    String? content,
    List<String>? images,
    String? videoUrl,
    Map<String, dynamic>? forestSnapshot,
    Map<String, dynamic>? walkingSnapshot,
    Map<String, dynamic>? badgeSnapshot,
    String? location,
    double? latitude,
    double? longitude,
    String? visibility,
    int? likeCount,
    int? commentCount,
    int? bookmarkCount,
    int? reportCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      forestSnapshot: forestSnapshot ?? this.forestSnapshot,
      walkingSnapshot: walkingSnapshot ?? this.walkingSnapshot,
      badgeSnapshot: badgeSnapshot ?? this.badgeSnapshot,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      visibility: visibility ?? this.visibility,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      reportCount: reportCount ?? this.reportCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static CommunityCategory _categoryFromString(dynamic value) {
    switch (value) {
      case "notice":
        return CommunityCategory.notice;
      case "challenge":
        return CommunityCategory.challenge;
      case "walking":
        return CommunityCategory.walking;
      case "forest":
        return CommunityCategory.forest;
      case "health":
        return CommunityCategory.health;
      case "photo":
        return CommunityCategory.photo;
      case "question":
        return CommunityCategory.question;
      case "event":
        return CommunityCategory.event;
      default:
        return CommunityCategory.free;
    }
  }
}
