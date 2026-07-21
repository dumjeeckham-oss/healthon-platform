import 'package:flutter/foundation.dart';

/// ===============================================================
///
/// FamilyMemberRanking
///
/// 가족 랭킹 모델
///
/// HealthON Release v1
///
/// ===============================================================

@immutable
class FamilyMemberRanking {
  /// 고유 ID
  final String id;

  /// 이름
  final String name;

  /// 프로필 이미지 URL
  final String? profileImageUrl;

  /// 이모지 아바타
  final String emoji;

  /// 오늘 걸음 수
  final int steps;

  /// 주간 걸음 수
  final int weeklySteps;

  /// 월간 걸음 수
  final int monthlySteps;

  /// 현재 레벨
  final int level;

  /// 연속 달성일
  final int streak;

  /// 성장률(%)
  final double growth;

  /// 응원받은 횟수
  final int cheers;

  /// 대표 배지
  final String badge;

  /// 가족장 여부
  final bool isLeader;

  /// 온라인 상태
  final bool isOnline;

  /// 마지막 활동시간
  final DateTime? lastActiveAt;

  const FamilyMemberRanking({
    required this.id,
    required this.name,
    required this.emoji,
    required this.steps,
    required this.weeklySteps,
    required this.monthlySteps,
    required this.level,
    required this.streak,
    required this.growth,
    required this.cheers,
    required this.badge,
    this.profileImageUrl,
    this.isLeader = false,
    this.isOnline = false,
    this.lastActiveAt,
  });

  /// 목표 달성률
  double progress({
    int goal = 10000,
  }) {
    final value = steps / goal;

    if (value < 0) return 0;
    if (value > 1) return 1;

    return value;
  }

  /// 목표 달성 여부
  bool get achievedGoal => steps >= 10000;

  /// 성장 여부
  bool get isGrowing => growth >= 0;

  /// 현재 상태
  String get status {

    if (steps >= 15000) {
      return "최고 컨디션";
    }

    if (steps >= 10000) {
      return "목표 달성";
    }

    if (steps >= 7000) {
      return "좋아요";
    }

    if (steps >= 4000) {
      return "조금만 더";
    }

    return "산책 추천";
  }

  /// 걸음 수 문자열
  String get formattedSteps {

    return _formatNumber(steps);

  }

  /// 주간 걸음 문자열
  String get formattedWeeklySteps {

    return _formatNumber(weeklySteps);

  }

  /// 월간 걸음 문자열
  String get formattedMonthlySteps {

    return _formatNumber(monthlySteps);

  }

  FamilyMemberRanking copyWith({
    String? id,
    String? name,
    String? profileImageUrl,
    String? emoji,
    int? steps,
    int? weeklySteps,
    int? monthlySteps,
    int? level,
    int? streak,
    double? growth,
    int? cheers,
    String? badge,
    bool? isLeader,
    bool? isOnline,
    DateTime? lastActiveAt,
  }) {

    return FamilyMemberRanking(

      id: id ?? this.id,

      name: name ?? this.name,

      profileImageUrl:
          profileImageUrl ?? this.profileImageUrl,

      emoji: emoji ?? this.emoji,

      steps: steps ?? this.steps,

      weeklySteps:
          weeklySteps ?? this.weeklySteps,

      monthlySteps:
          monthlySteps ?? this.monthlySteps,

      level: level ?? this.level,

      streak: streak ?? this.streak,

      growth: growth ?? this.growth,

      cheers: cheers ?? this.cheers,

      badge: badge ?? this.badge,

      isLeader: isLeader ?? this.isLeader,

      isOnline: isOnline ?? this.isOnline,

      lastActiveAt:
          lastActiveAt ?? this.lastActiveAt,

    );

  }

  Map<String, dynamic> toJson() {

    return {

      "id": id,

      "name": name,

      "profileImageUrl": profileImageUrl,

      "emoji": emoji,

      "steps": steps,

      "weeklySteps": weeklySteps,

      "monthlySteps": monthlySteps,

      "level": level,

      "streak": streak,

      "growth": growth,

      "cheers": cheers,

      "badge": badge,

      "isLeader": isLeader,

      "isOnline": isOnline,

      "lastActiveAt": lastActiveAt?.toIso8601String(),

    };

  }

  factory FamilyMemberRanking.fromJson(
    Map<String, dynamic> json,
  ) {

    return FamilyMemberRanking(

      id: json["id"] ?? "",

      name: json["name"] ?? "",

      profileImageUrl: json["profileImageUrl"],

      emoji: json["emoji"] ?? "🙂",

      steps: json["steps"] ?? 0,

      weeklySteps: json["weeklySteps"] ?? 0,

      monthlySteps: json["monthlySteps"] ?? 0,

      level: json["level"] ?? 1,

      streak: json["streak"] ?? 0,

      growth: (json["growth"] ?? 0).toDouble(),

      cheers: json["cheers"] ?? 0,

      badge: json["badge"] ?? "🏅",

      isLeader: json["isLeader"] ?? false,

      isOnline: json["isOnline"] ?? false,

      lastActiveAt: json["lastActiveAt"] == null
          ? null
          : DateTime.parse(json["lastActiveAt"]),

    );

  }

  static String _formatNumber(int value) {

    final text = value.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {

      buffer.write(text[i]);

      final position = text.length - i - 1;

      if (position > 0 && position % 3 == 0) {
        buffer.write(",");
      }

    }

    return buffer.toString();

  }

  @override
  String toString() {

    return 'FamilyMemberRanking('
        'id: $id, '
        'name: $name, '
        'steps: $steps, '
        'level: $level'
        ')';

  }

  @override
  bool operator ==(Object other) {

    if (identical(this, other)) return true;

    return other is FamilyMemberRanking &&
        other.id == id;

  }

  @override
  int get hashCode => id.hashCode;
}
