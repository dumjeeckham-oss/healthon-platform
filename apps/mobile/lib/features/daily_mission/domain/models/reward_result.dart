enum RewardPresentationType {
  levelUp,
  treeUnlock,
  badge,
  gardenUnlock,
  seasonReward,
  rareAnimal,
}

/// ===============================================================
/// HealthON Reward Result
/// Mission 완료 후 RewardFlow가 반환하는 결과 모델
/// ===============================================================

class RewardResult {
  final int xp;
  final int leaf;
  final int seed;
  final int coin;
  final bool levelUp;
  final int oldLevel;
  final int newLevel;
  final bool newTreeUnlocked;
  final String? treeName;
  final bool badgeUnlocked;
  final String? badgeCode;
  final bool gardenUnlocked;
  final String? gardenTileId;
  final int gainedExp;
  final List<RewardPresentationType> queue;

  const RewardResult({
    this.xp = 0,
    this.leaf = 0,
    this.seed = 0,
    this.coin = 0,
    this.levelUp = false,
    this.oldLevel = 0,
    this.newLevel = 0,
    this.newTreeUnlocked = false,
    this.treeName,
    this.badgeUnlocked = false,
    this.badgeCode,
    this.gardenUnlocked = false,
    this.gardenTileId,
    this.gainedExp = 0,
    this.queue = const [],
  });

  factory RewardResult.empty() {
    return const RewardResult();
  }

  RewardResult copyWith({
    int? xp,
    int? leaf,
    int? seed,
    int? coin,
    bool? levelUp,
    int? oldLevel,
    int? newLevel,
    bool? newTreeUnlocked,
    String? treeName,
    bool? badgeUnlocked,
    String? badgeCode,
    bool? gardenUnlocked,
    String? gardenTileId,
    int? gainedExp,
    List<RewardPresentationType>? queue,
  }) {
    return RewardResult(
      xp: xp ?? this.xp,
      leaf: leaf ?? this.leaf,
      seed: seed ?? this.seed,
      coin: coin ?? this.coin,
      levelUp: levelUp ?? this.levelUp,
      oldLevel: oldLevel ?? this.oldLevel,
      newLevel: newLevel ?? this.newLevel,
      newTreeUnlocked: newTreeUnlocked ?? this.newTreeUnlocked,
      treeName: treeName ?? this.treeName,
      badgeUnlocked: badgeUnlocked ?? this.badgeUnlocked,
      badgeCode: badgeCode ?? this.badgeCode,
      gardenUnlocked: gardenUnlocked ?? this.gardenUnlocked,
      gardenTileId: gardenTileId ?? this.gardenTileId,
      gainedExp: gainedExp ?? this.gainedExp,
      queue: queue ?? this.queue,
    );
  }

  bool get hasReward {
    return xp > 0 || leaf > 0 || seed > 0 || coin > 0;
  }

  bool get hasPopup {
    return queue.isNotEmpty;
  }

  @override
  String toString() {
    return 'RewardResult(xp: $xp, leaf: $leaf, seed: $seed, coin: $coin, '
        'levelUp: $levelUp, oldLevel: $oldLevel, newLevel: $newLevel, '
        'newTreeUnlocked: $newTreeUnlocked, treeName: $treeName, '
        'badgeUnlocked: $badgeUnlocked, badgeCode: $badgeCode, '
        'gardenUnlocked: $gardenUnlocked, gardenTileId: $gardenTileId, '
        'gainedExp: $gainedExp, queue: $queue)';
  }
}
