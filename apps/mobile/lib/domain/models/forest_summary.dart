class ForestSummary {
  final double totalKm;
  final int treeLevel;
  final double treeExp;
  final double nextLevelExp;
  final String treeName;

  const ForestSummary({
    required this.totalKm,
    required this.treeLevel,
    required this.treeExp,
    required this.nextLevelExp,
    required this.treeName,
  });

  double get progress =>
      nextLevelExp == 0 ? 1 : treeExp / nextLevelExp;
}
