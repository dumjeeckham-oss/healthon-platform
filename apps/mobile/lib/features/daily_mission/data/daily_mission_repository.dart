import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/daily_mission.dart';
import '../application/mission_engine.dart';

class DailyMissionRepository {
  DailyMissionRepository();

  final SupabaseClient _client = Supabase.instance.client;

  final MissionEngine _engine = const MissionEngine();

  //------------------------------------------------------------
  // 오늘 미션 조회
  //------------------------------------------------------------

  Future<List<DailyMission>> getTodayMissions(
    String userId,
  ) async {
    final result = await _client
        .from("user_daily_missions")
        .select()
        .eq("user_id", userId)
        .eq(
          "mission_date",
          DateTime.now().toIso8601String().substring(0, 10),
        );

    if ((result as List).isEmpty) {
      await generateToday(userId);

      return getTodayMissions(userId);
    }

    return result
        .map(
          (e) => DailyMission.fromMap(e),
        )
        .toList();
  }

  //------------------------------------------------------------
  // 오늘 미션 생성
  //------------------------------------------------------------

  Future<void> generateToday(
    String userId,
  ) async {
    final missions = _engine.defaultMissions();

    for (final mission in missions) {
      await _client.from("user_daily_missions").insert({
        "user_id": userId,
        "mission_key": mission.missionKey,
        "title": mission.title,
        "description": mission.description,
        "icon": mission.icon,
        "mission_type": mission.missionType,
        "goal": mission.goal,
        "progress": 0,
        "completed": false,
        "claimed": false,
        "reward_type": mission.rewardType,
        "reward_value": mission.rewardValue,
        "mission_date":
            DateTime.now().toIso8601String().substring(0, 10),
      });
    }
  }

  //------------------------------------------------------------
  // 진행률 저장
  //------------------------------------------------------------

  Future<void> updateProgress({
    required String missionId,
    required int progress,
    required bool completed,
  }) async {
    await _client
        .from("user_daily_missions")
        .update({
          "progress": progress,
          "completed": completed,
        })
        .eq("id", missionId);
  }

  //------------------------------------------------------------
  // 보상 수령
  //------------------------------------------------------------

  Future<void> claimReward(
    String missionId,
  ) async {
    await _client
        .from("user_daily_missions")
        .update({
          "claimed": true,
        })
        .eq("id", missionId);
  }

  //------------------------------------------------------------
  // 진행률 계산 + 저장
  //------------------------------------------------------------

  Future<List<DailyMission>> refreshProgress({
    required String userId,
    required int totalSteps,
    required double totalKm,
    required int forestLevel,
    required bool aiVisited,
    required int familyCheers,
  }) async {
    final missions =
        await getTodayMissions(userId);

    final updated = _engine.updateAll(
      missions: missions,
      totalSteps: totalSteps,
      totalKm: totalKm,
      forestLevel: forestLevel,
      aiVisited: aiVisited,
      familyCheers: familyCheers,
    );

    for (final mission in updated) {
      await updateProgress(
        missionId: mission.id,
        progress: mission.progress,
        completed: mission.completed,
      );
    }

    return updated;
  }
}
