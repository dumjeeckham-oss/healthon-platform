class ForestBadge {
  final String code;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;

  const ForestBadge({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  /// DB(Map) → 객체
  factory ForestBadge.fromMap(Map<String, dynamic> map) {
    return ForestBadge(
      code: map['badge_key'] ?? '',
      title: map['badge_name'] ?? '',
      description: map['description'] ?? '',
      icon: map['badge_icon'] ?? '🏅',
      unlocked: true,
    );
  }

  /// 객체 → DB
  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'badge_key': code,
      'badge_name': title,
      'description': description,
      'badge_icon': icon,
    };
  }

  /// 코드 → 기본 Badge 생성
  factory ForestBadge.fromCode(
    String code,
    bool unlocked,
  ) {
    switch (code) {
      case "FIRST_STEP":
        return ForestBadge(
          code: code,
          title: "첫 걸음",
          description: "10km 달성",
          icon: "👣",
          unlocked: unlocked,
        );

      case "WALKER":
        return ForestBadge(
          code: code,
          title: "워커",
          description: "50km 달성",
          icon: "🚶",
          unlocked: unlocked,
        );

      case "MARATHON":
        return ForestBadge(
          code: code,
          title: "마라토너",
          description: "100km 달성",
          icon: "🏃",
          unlocked: unlocked,
        );

      case "TREE_LV5":
        return ForestBadge(
          code: code,
          title: "새싹 성장",
          description: "Tree Level 5 달성",
          icon: "🌱",
          unlocked: unlocked,
        );

      case "TREE_LV10":
        return ForestBadge(
          code: code,
          title: "큰 나무",
          description: "Tree Level 10 달성",
          icon: "🌳",
          unlocked: unlocked,
        );

      case "TREE_LV20":
        return ForestBadge(
          code: code,
          title: "생명의 숲",
          description: "Tree Level 20 달성",
          icon: "🌲",
          unlocked: unlocked,
        );

      default:
        return ForestBadge(
          code: code,
          title: code,
          description: "",
          icon: "🏅",
          unlocked: unlocked,
        );
    }
  }

  ForestBadge copyWith({
    bool? unlocked,
  }) {
    return ForestBadge(
      code: code,
      title: title,
      description: description,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}
