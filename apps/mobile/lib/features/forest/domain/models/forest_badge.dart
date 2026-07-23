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
          description: "Tree Lv5",
          icon: "🌱",
          unlocked: unlocked,
        );

      case "TREE_LV10":
        return ForestBadge(
          code: code,
          title: "큰 나무",
          description: "Tree Lv10",
          icon: "🌳",
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
}
