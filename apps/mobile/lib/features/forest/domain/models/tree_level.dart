class TreeLevel {
  final int level;
  final String name;
  final String emoji;
  final double requiredKm;

  const TreeLevel({
    required this.level,
    required this.name,
    required this.emoji,
    required this.requiredKm,
  });

  factory TreeLevel.fromLevel(int level) {
    return treeLevels.firstWhere(
      (t) => t.level == level,
      orElse: () => treeLevels.first,
    );
  }
}

///
/// Forest 성장 테이블
///
const treeLevels = [

  TreeLevel(level: 1, name: "새싹", emoji: "🌱", requiredKm: 0),

  TreeLevel(level: 2, name: "묘목", emoji: "🌿", requiredKm: 100),

  TreeLevel(level: 3, name: "어린나무", emoji: "🪴", requiredKm: 250),

  TreeLevel(level: 4, name: "푸른나무", emoji: "🌲", requiredKm: 500),

  TreeLevel(level: 5, name: "큰나무", emoji: "🌳", requiredKm: 800),

  TreeLevel(level: 6, name: "거목", emoji: "🏛️", requiredKm: 1200),

  TreeLevel(level: 7, name: "생명의나무", emoji: "✨", requiredKm: 1700),

  TreeLevel(level: 8, name: "신목", emoji: "👑", requiredKm: 2300),

  TreeLevel(level: 9, name: "세계수", emoji: "🌍", requiredKm: 3000),
];

TreeLevel calculateTreeLevel(double km) {

  TreeLevel current = treeLevels.first;

  for (final level in treeLevels) {

    if (km >= level.requiredKm) {

      current = level;

    } else {

      break;

    }
  }

  return current;
}
