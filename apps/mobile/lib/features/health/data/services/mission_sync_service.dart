/// ===============================================================
/// HealthON — Mission Sync Service
///
/// health_daily.steps → Mission 자동 완료 체크
/// 예) 오늘 7000걸음 → Mission 자동 완료 → Reward 지급
/// ===============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

class MissionSyncService {
  final SupabaseClient _client;

  MissionSyncService(this._client);

  /// health_daily 오늘 걸음 기준 Mission 체크 & 완료
  Future<int> checkAndCompleteMissions(String userId) async {
    // 1. 오늘 걸음 수 조회
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final daily = await _client
        .from('health_daily')
        .select('steps')
        .eq('user_id', userId)
        .eq('date', todayStr)
        .maybeSingle();

    if (daily == null) return 0;

    final todaySteps = (daily['steps'] ?? 0) as int;

    // 2. 진행 중인 Mission 조회 (걸음 기반 미션만)
    final missions = await _client
        .from('daily_missions')
        .select()
        .eq('user_id', userId)
        .eq('completed', false)
        .order('target_steps', ascending: true);

    int completedCount = 0;

    for (final mission in missions as List) {
      final targetSteps = (mission['target_steps'] ?? 0) as int;
      final missionId = mission['id'] as String;
      final rewardType = mission['reward_type'] as String? ?? '';
      final rewardAmount = (mission['reward_amount'] ?? 0) as int;

      if (todaySteps >= targetSteps) {
        // Mission 완료 처리
        await _client.from('daily_missions').update({
          'completed': true,
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', missionId);

        // Reward 지급
        if (rewardAmount > 0) {
          await _giveReward(userId, rewardType, rewardAmount, missionId);
        }

        completedCount++;
      }
    }

    return completedCount;
  }

  Future<void> _giveReward(
    String userId,
    String rewardType,
    int amount,
    String missionId,
  ) async {
    switch (rewardType) {
      case 'exp':
        // Forest 경험치 지급
        final current = await _client
            .from('forest_progress')
            .select('tree_exp')
            .eq('user_id', userId)
            .maybeSingle();

        final currentExp = (current?['tree_exp'] ?? 0).toDouble();
        await _client.from('forest_progress').upsert({
          'user_id': userId,
          'tree_exp': currentExp + amount,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
        break;

      case 'coin':
      case 'point':
      default:
        // 포인트 지급 — reward_logs에 기록
        await _client.from('reward_logs').insert({
          'user_id': userId,
          'type': 'mission',
          'amount': amount,
          'description': 'Mission 완료 보상',
          'reference_id': missionId,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
        break;
    }
  }
}
