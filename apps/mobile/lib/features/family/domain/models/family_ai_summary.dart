import 'package:flutter/foundation.dart';

/// ===============================================================
///
/// Family AI Summary
///
/// 가족 전체 활동을 AI가 분석하기 위한 모델
///
/// HealthON Release v1
///
/// ===============================================================

@immutable
class FamilyAiSummary {
  /// 가족 행복지수 (0~100)
  final double happinessScore;

  /// 목표 달성률 (0~1)
  final double goalProgress;

  /// 오늘 총 걸음
  final int totalSteps;

  /// 참여 인원
  final int memberCount;

  /// 평균 걸음
  final int averageSteps;

  /// 지난주 대비 변화율
  final double weeklyGrowth;

  /// 연속 목표 달성일
  final int familyStreak;

  /// 오늘의 AI 메시지
  final String coachMessage;

  /// 추천 미션
  final String todayMission;

  /// 가족 응원 메시지
  final String encouragement;

  const FamilyAiSummary({
    required this.happinessScore,
    required this.goalProgress,
    required this.totalSteps,
    required this.memberCount,
    required this.averageSteps,
    required this.weeklyGrowth,
    required this.familyStreak,
    required this.coachMessage,
    required this.todayMission,
    required this.encouragement,
  });

  /// 최고 컨디션 여부
  bool get isExcellent =>
      happinessScore >= 90;

  /// 목표 달성 여부
  bool get goalCompleted =>
      goalProgress >= 1.0;

  /// 행복지수 문자열
  String get happinessLabel =>
      "${happinessScore.toStringAsFixed(0)}점";

  /// 목표 달성률 문자열
  String get progressLabel =>
      "${(goalProgress * 100).toStringAsFixed(0)}%";

  /// AI 상태
  String get healthState {
    if (happinessScore >= 90) {
      return "최고";
    }

    if (happinessScore >= 70) {
      return "좋음";
    }

    if (happinessScore >= 50) {
      return "보통";
    }

    return "관리 필요";
  }

  FamilyAiSummary copyWith({
    double? happinessScore,
    double? goalProgress,
    int? totalSteps,
    int? memberCount,
    int? averageSteps,
    double? weeklyGrowth,
    int? familyStreak,
    String? coachMessage,
    String? todayMission,
    String? encouragement,
  }) {
    return FamilyAiSummary(
      happinessScore:
          happinessScore ?? this.happinessScore,
      goalProgress:
          goalProgress ?? this.goalProgress,
      totalSteps:
          totalSteps ?? this.totalSteps,
      memberCount:
          memberCount ?? this.memberCount,
      averageSteps:
          averageSteps ?? this.averageSteps,
      weeklyGrowth:
          weeklyGrowth ?? this.weeklyGrowth,
      familyStreak:
          familyStreak ?? this.familyStreak,
      coachMessage:
          coachMessage ?? this.coachMessage,
      todayMission:
          todayMission ?? this.todayMission,
      encouragement:
          encouragement ?? this.encouragement,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "happinessScore": happinessScore,
      "goalProgress": goalProgress,
      "totalSteps": totalSteps,
      "memberCount": memberCount,
      "averageSteps": averageSteps,
      "weeklyGrowth": weeklyGrowth,
      "familyStreak": familyStreak,
      "coachMessage": coachMessage,
      "todayMission": todayMission,
      "encouragement": encouragement,
    };
  }

  factory FamilyAiSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return FamilyAiSummary(
      happinessScore:
          (json["happinessScore"] ?? 0).toDouble(),
      goalProgress:
          (json["goalProgress"] ?? 0).toDouble(),
      totalSteps:
          json["totalSteps"] ?? 0,
      memberCount:
          json["memberCount"] ?? 0,
      averageSteps:
          json["averageSteps"] ?? 0,
      weeklyGrowth:
          (json["weeklyGrowth"] ?? 0).toDouble(),
      familyStreak:
          json["familyStreak"] ?? 0,
      coachMessage:
          json["coachMessage"] ?? "",
      todayMission:
          json["todayMission"] ?? "",
      encouragement:
          json["encouragement"] ?? "",
    );
  }

  @override
  String toString() {
    return "FamilyAiSummary("
        "score: $happinessScore, "
        "progress: $goalProgress, "
        "steps: $totalSteps"
        ")";
  }
}
