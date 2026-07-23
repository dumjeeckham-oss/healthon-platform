class ForestSpecies {
  final String id;
  final int level;
  final String name;
  final String emoji;
  final String description;
  final String image;
  final bool isUnlocked;

  const ForestSpecies({
    required this.id,
    required this.level,
    required this.name,
    required this.emoji,
    required this.description,
    required this.image,
    required this.isUnlocked,
  });

  ForestSpecies copyWith({
    bool? isUnlocked,
  }) {
    return ForestSpecies(
      id: id,
      level: level,
      name: name,
      emoji: emoji,
      description: description,
      image: image,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
