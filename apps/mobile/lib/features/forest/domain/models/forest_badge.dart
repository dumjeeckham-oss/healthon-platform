class ForestBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool earned;

  const ForestBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earned,
  });

  factory ForestBadge.fromMap(Map<String, dynamic> map) {
    return ForestBadge(
      id: map["badge_id"],
      title: map["title"],
      description: map["description"],
      icon: map["icon"],
      earned: true,
    );
  }
}
