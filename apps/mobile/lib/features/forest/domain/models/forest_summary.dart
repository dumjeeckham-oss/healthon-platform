import 'tree_level.dart';

class ForestSummary {

  final double totalKm;

  final int treeLevel;

  final String treeName;

  final double treeExp;

  final double nextLevelExp;

  const ForestSummary({

    required this.totalKm,

    required this.treeLevel,

    required this.treeName,

    required this.treeExp,

    required this.nextLevelExp,
  });

  double get progress {

    if (nextLevelExp <= 0) {
      return 1;
    }

    return (treeExp / nextLevelExp).clamp(0.0, 1.0);
  }

  factory ForestSummary.empty() {

    return const ForestSummary(

      totalKm: 0,

      treeLevel: 1,

      treeName: "새싹",

      treeExp: 0,

      nextLevelExp: 100,
    );
  }

  factory ForestSummary.fromKm(double km) {

    final current = calculateTreeLevel(km);

    final index = treeLevels.indexOf(current);

    final currentStart = current.requiredKm;

    final nextGoal = index == treeLevels.length - 1
        ? current.requiredKm
        : treeLevels[index + 1].requiredKm;

    final exp = km - currentStart;

    final need = nextGoal - currentStart;

    return ForestSummary(

      totalKm: km,

      treeLevel: current.level,

      treeName: current.name,

      treeExp: exp,

      nextLevelExp: need,
    );
  }

  factory ForestSummary.fromMap(Map<String, dynamic> map) {

    final km = (map["total_km"] ?? 0).toDouble();

    return ForestSummary.fromKm(km);
  }

  Map<String, dynamic> toMap() {

    return {

      "total_km": totalKm,

      "tree_level": treeLevel,

      "tree_exp": treeExp,

      "next_level_exp": nextLevelExp,
    };
  }
}
