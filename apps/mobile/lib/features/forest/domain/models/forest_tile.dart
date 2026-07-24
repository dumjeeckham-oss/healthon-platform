import 'package:flutter/foundation.dart';

/// 숲 타일의 종류
enum ForestTileType {
  empty,
  tree,
  decoration,
  animal,
}

/// 숲 타일 모델
@immutable
class ForestTile {
  final int x;
  final int y;

  /// 타일 종류
  final ForestTileType type;

  /// 나무 또는 장식 ID
  final String? objectId;

  /// SVG 또는 이미지 경로
  final String? asset;

  /// 잠금 여부
  final bool unlocked;

  /// 심어져 있는지 여부
  final bool planted;

  /// 현재 나무 레벨
  final int level;

  /// 경험치
  final double exp;

  /// 성장률 (0~1)
  final double progress;

  /// 생성일
  final DateTime? plantedAt;

  const ForestTile({
    required this.x,
    required this.y,
    this.type = ForestTileType.empty,
    this.objectId,
    this.asset,
    this.unlocked = false,
    this.planted = false,
    this.level = 1,
    this.exp = 0,
    this.progress = 0,
    this.plantedAt,
  });

  /// 빈 타일 생성
  factory ForestTile.empty({
    required int x,
    required int y,
  }) {
    return ForestTile(
      x: x,
      y: y,
      type: ForestTileType.empty,
      unlocked: false,
      planted: false,
    );
  }

  ForestTile copyWith({
    int? x,
    int? y,
    ForestTileType? type,
    String? objectId,
    String? asset,
    bool? unlocked,
    bool? planted,
    int? level,
    double? exp,
    double? progress,
    DateTime? plantedAt,
  }) {
    return ForestTile(
      x: x ?? this.x,
      y: y ?? this.y,
      type: type ?? this.type,
      objectId: objectId ?? this.objectId,
      asset: asset ?? this.asset,
      unlocked: unlocked ?? this.unlocked,
      planted: planted ?? this.planted,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      progress: progress ?? this.progress,
      plantedAt: plantedAt ?? this.plantedAt,
    );
  }

  factory ForestTile.fromMap(Map<String, dynamic> map) {
    return ForestTile(
      x: map["x"] ?? 0,
      y: map["y"] ?? 0,
      type: ForestTileType.values.firstWhere(
        (e) => e.name == map["type"],
        orElse: () => ForestTileType.empty,
      ),
      objectId: map["object_id"],
      asset: map["asset"],
      unlocked: map["unlocked"] ?? false,
      planted: map["planted"] ?? false,
      level: map["level"] ?? 1,
      exp: (map["exp"] ?? 0).toDouble(),
      progress: (map["progress"] ?? 0).toDouble(),
      plantedAt: map["planted_at"] == null
          ? null
          : DateTime.parse(map["planted_at"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "pos_x": x,
      "pos_y": y,
      "type": type.name,
      "species_id": objectId,
      "asset": asset,
      "unlocked": unlocked,
      "planted": planted,
      "level": level,
      "exp": exp,
      "progress": progress,
      "planted_at": plantedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ForestTile(x: $x, y: $y, type: ${type.name}, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ForestTile &&
            runtimeType == other.runtimeType &&
            x == other.x &&
            y == other.y &&
            type == other.type &&
            objectId == other.objectId &&
            unlocked == other.unlocked &&
            planted == other.planted &&
            level == other.level;
  }

  @override
  int get hashCode {
    return Object.hash(
      x,
      y,
      type,
      objectId,
      unlocked,
      planted,
      level,
    );
  }
}
