import '../domain/models/daily_mission.dart';

/// ===============================================================
///
/// HealthON Mission Engine
///
/// 오늘의 미션 진행률 계산 엔진
///
/// 앞으로
///
/// - Daily Mission
/// - Weekly Mission
/// - Event Mission
/// - Season Mission
///
/// 모두 여기서 처리한다.
///
/// ===============================================================
class MissionEngine {
  const MissionEngine();

  /// ---------------------------------------------------------------
  /// 진행률 계산
  /// ---------------------------------------------------------------
  DailyMission updateMission({
    required DailyMission mission,
    required int currentValue,
  }) {
    final progress =
        currentValue > mission.goal
            ? mission.goal
            : currentValue;

    final completed =
        progress >= mission.goal;

    return mission.copyWith(
      progress: progress,
      completed: completed,
    );
  }

  /// ---------------------------------------------------------------
  /// 여러 미션 한번에 계산
  /// ---------------------------------------------------------------
  List<DailyMission> updateAll({
    required List<DailyMission> missions,
    required int totalSteps,
    required double totalKm,
    required int forestLevel,
    required bool aiVisited,
    required int familyCheers,
  }) {
    return missions.map((mission) {
      switch (mission.missionType) {
        //------------------------------------------------------------
        // 걸음수
        //------------------------------------------------------------
        case "STEP":
          return updateMission(
            mission: mission,
            currentValue: totalSteps,
          );

        //------------------------------------------------------------
        // 거리
        //------------------------------------------------------------
        case "DISTANCE":
          return updateMission(
            mission: mission,
            currentValue: totalKm.floor(),
          );

        //------------------------------------------------------------
        // Forest 방문
        //------------------------------------------------------------
        case "FOREST":
          return updateMission(
            mission: mission,
            currentValue: forestLevel > 0 ? 1 : 0,
          );

        //------------------------------------------------------------
        // AI Coach
        //------------------------------------------------------------
        case "AI":
          return updateMission(
            mission: mission,
            currentValue: aiVisited ? 1 : 0,
          );

        //------------------------------------------------------------
        // 가족 응원
        //------------------------------------------------------------
        case "FAMILY":
          return updateMission(
            mission: mission,
            currentValue: familyCheers,
          );

        //------------------------------------------------------------
        // 기본
        //------------------------------------------------------------
        default:
          return mission;
      }
    }).toList();
  }

  /// ---------------------------------------------------------------
  /// 보상 수령 가능
  /// ---------------------------------------------------------------
  bool canClaim(DailyMission mission) {
    return mission.completed && !mission.claimed;
  }

  /// ---------------------------------------------------------------
  /// 보상 수령 처리
  /// ---------------------------------------------------------------
  DailyMission claim(DailyMission mission) {
    if (!canClaim(mission)) {
      return mission;
    }

    return mission.copyWith(
      claimed: true,
    );
  }

  /// ---------------------------------------------------------------
  /// 오늘 미션 생성 (기본 템플릿)
  /// ---------------------------------------------------------------
  List<DailyMission> defaultMissions() {
    return [
      DailyMission(
        id: "1",
        missionKey: "STEP_5000",
        title: "5,000걸음 걷기",
        description: "오늘 5,000걸음을 달성하세요.",
        icon: "🚶",
        missionType: "STEP",
        goal: 5000,
        progress: 0,
        completed: false,
        claimed: false,
        rewardType: "XP",
        rewardValue: 5,
      ),

      DailyMission(
        id: "2",
        missionKey: "STEP_10000",
        title: "10,000걸음 걷기",
        description: "오늘 10,000걸음을 달성하세요.",
        icon: "🏃",
        missionType: "STEP",
        goal: 10000,
        progress: 0,
        completed: false,
        claimed: false,
        rewardType: "LEAF",
        rewardValue: 20,
      ),

      DailyMission(
        id: "3",
        missionKey: "FOREST_VISIT",
        title: "Forest 방문",
        description: "오늘 숲을 방문하세요.",
        icon: "🌳",
        missionType: "FOREST",
        goal: 1,
        progress: 0,
        completed: false,
        claimed: false,
        rewardType: "SEED",
        rewardValue: 1,
      ),

      DailyMission(
        id: "4",
        missionKey: "AI_VISIT",
        title: "AI 코치 만나기",
        description: "AI 코치와 대화해보세요.",
        icon: "🤖",
        missionType: "AI",
        goal: 1,
        progress: 0,
        completed: false,
        claimed: false,
        rewardType: "XP",
        rewardValue: 3,
      ),

      DailyMission(
        id: "5",
        missionKey: "CHEER",
        title: "가족 응원하기",
        description: "가족을 3번 응원하세요.",
        icon: "❤️",
        missionType: "FAMILY",
        goal: 3,
        progress: 0,
        completed: false,
        claimed: false,
        rewardType: "COIN",
        rewardValue: 10,
      ),
    ];
  }
}
