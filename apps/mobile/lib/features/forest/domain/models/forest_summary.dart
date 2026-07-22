class ForestSummary {
  final double totalKm;
  final int treeLevel;
  final double treeExp;
  final double nextLevelExp;

  const ForestSummary({
    required this.totalKm,
    required this.treeLevel,
    required this.treeExp,
    required this.nextLevelExp,
  });

  double get progress {

  if (nextLevelExp == 0) return 1;

  return treeExp / nextLevelExp;

}

  String get treeName {
    switch (treeLevel) {
      case 1:
        return "새싹";
      case 2:
        return "어린 나무";
      case 3:
        return "푸른 나무";
      case 4:
        return "큰 나무";
      default:
        return "건강 숲";
    }
  }

  factory ForestSummary.fromMap(Map<String, dynamic> json) {
    return ForestSummary(
      totalKm: (json["total_km"] ?? 0).toDouble(),
      treeLevel: json["tree_level"] ?? 1,
      treeExp: (json["tree_exp"] ?? 0).toDouble(),
      nextLevelExp: (json["next_level_exp"] ?? 100).toDouble(),
    );
  }

  factory ForestSummary.empty() {
    return const ForestSummary(
      totalKm: 0,
      treeLevel: 1,
      treeExp: 0,
      nextLevelExp: 100,
    );
  }
}
