/// ===============================================================
///
/// HealthON Reward Result
///
/// Mission 완료 후
///
/// RewardFlow가 반환하는 결과 모델
///
/// ===============================================================

class RewardResult {
  /// 지급된 XP
  final int xp;

  /// Leaf
  final int leaf;

  /// Seed
  final int seed;

  /// Coin
  final int coin;

  /// 레벨업 여부
  final bool levelUp;

  /// 이전 레벨
  final int oldLevel;

  /// 현재 레벨
  final int newLevel;

  /// 새 나무 해금 여부
  final bool newTreeUnlocked;

  /// 새 나무 이름
  final String? treeName;

  /// 새 배지 획득 여부
  final bool badgeUnlocked;

  /// 배지 코드
  final String? badgeCode;

  /// Garden 해금 여부
  final bool gardenUnlocked;

  /// Garden Tile ID
  final String? gardenTileId;

  /// Forest 경험치
  final int gainedExp;

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
  });

  /// ===============================================================
  /// Empty
  /// ===============================================================

  factory RewardResult.empty() {
    return const RewardResult();
  }

  /// ===============================================================
  /// copyWith
  /// ===============================================================

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
  }) {
    return RewardResult(
      xp: xp ?? this.xp,
      leaf: leaf ?? this.leaf,
      seed: seed ?? this.seed,
      coin: coin ?? this.coin,

      levelUp: levelUp ?? this.levelUp,

      oldLevel: oldLevel ?? this.oldLevel,
      newLevel: newLevel ?? this.newLevel,

      newTreeUnlocked:
          newTreeUnlocked ?? this.newTreeUnlocked,

      treeName: treeName ?? this.treeName,

      badgeUnlocked:
          badgeUnlocked ?? this.badgeUnlocked,

      badgeCode: badgeCode ?? this.badgeCode,

      gardenUnlocked:
          gardenUnlocked ?? this.gardenUnlocked,

      gardenTileId:
          gardenTileId ?? this.gardenTileId,

      gainedExp:
          gainedExp ?? this.gainedExp,
    );
  }

  /// ===============================================================
  /// 보상이 하나라도 있는가
  /// ===============================================================

  bool get hasReward {
    return xp > 0 ||
        leaf > 0 ||
        seed > 0 ||
        coin > 0;
  }

  /// ===============================================================
  /// Popup 필요 여부
  /// ===============================================================

  bool get hasPopup {
    return levelUp ||
        badgeUnlocked ||
        newTreeUnlocked ||
        gardenUnlocked;
  }

  /// ===============================================================
  /// 디버그 출력
  /// ===============================================================

  @override
  String toString() {
    return '''
RewardResult(
  xp: $xp,
  leaf: $leaf,
  seed: $seed,
  coin: $coin,

  levelUp: $levelUp,

  oldLevel: $oldLevel,
  newLevel: $newLevel,

  newTreeUnlocked: $newTreeUnlocked,
  treeName: $treeName,

  badgeUnlocked: $badgeUnlocked,
  badgeCode: $badgeCode,

  gardenUnlocked: $gardenUnlocked,
  gardenTileId: $gardenTileId,

  gainedExp: $gainedExp,
)
''';
  }
}
