/// ===============================================================
/// HealthON — Forest Sync Service (v2 — Social Engine 연동)
///
/// health_daily.steps 합계 → Forest tree 성장률 자동 연동
/// Forest 레벨업 시 ActivityEvent 자동 발생
/// ===============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../social_engine/activity_engine.dart';
import '../../../social_engine/activity_models.dart';

class ForestSyncService {
  final SupabaseClient _client;

  ForestSyncService(this._client);

  double stepsToKm(int steps) => (steps * 0.7) / 1000.0;

  /// health_daily.steps 총합 → forest_progress 업데이트 + 레벨업 이벤트
  Future<Map<String, Object>?> syncForestFromHealth(String userId) async {
    // 1. health_daily 전체 steps 합계 조회
    final result = await _client
        .from('health_daily')
        .select('steps')
        .eq('user_id', userId);

    int totalSteps = 0;
    for (final row in result as List) {
      totalSteps += (row['steps'] ?? 0) as int;
    }

    final totalKm = stepsToKm(totalSteps);

    // 2. 이전 레벨 조회
    final oldForest = await _client
        .from('forest_progress')
        .select('tree_level')
        .eq('user_id', userId)
        .maybeSingle();

    final int oldLevel = (oldForest?['tree_level'] ?? 1) as int;

    // 3. 새 레벨 계산
    final forest = await _getForestLevel(totalKm);
    final int newLevel = forest['level'] as int;

    // 4. forest_progress 업데이트
    await _client.from('forest_progress').upsert({
      'user_id': userId,
      'total_km': totalKm,
      'total_steps': totalSteps,
      'tree_level': newLevel,
      'tree_exp': forest['exp'],
      'next_level_exp': forest['nextExp'],
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    // 5. 레벨업 시 Social Engine 이벤트 발생
    if (newLevel > oldLevel) {
      try {
        final engine = ActivityEngine(_client);
        await engine.emitForestLevelUp(
          userId: userId,
          oldLevel: oldLevel,
          newLevel: newLevel,
          treeName: forest['name'] as String,
          totalSteps: totalSteps,
        );
      } catch (e) {
        print('ForestSync: activity event failed — $e');
      }
    }

    return forest;
  }

  /// 걸음 기반 Forest 레벨/경험치 계산
  Future<Map<String, Object>> _getForestLevel(double totalKm) async {
    final totalSteps = (totalKm * 1000 / 0.7).round();

    final levels = [
      {'level': 1, 'name': '새싹', 'steps': 0},
      {'level': 2, 'name': '묘목', 'steps': 5000},
      {'level': 3, 'name': '어린나무', 'steps': 15000},
      {'level': 4, 'name': '성장나무', 'steps': 30000},
      {'level': 5, 'name': '큰나무', 'steps': 50000},
      {'level': 6, 'name': '숲', 'steps': 80000},
      {'level': 7, 'name': '울창한숲', 'steps': 120000},
      {'level': 8, 'name': '열대우림', 'steps': 200000},
    ];

    int currentLevel = 1;
    int currentExp = totalSteps;
    int nextExp = 5000;

    for (int i = 0; i < levels.length; i++) {
      final threshold = levels[i]['steps'] as int;
      if (totalSteps >= threshold) {
        currentLevel = levels[i]['level'] as int;
        final nextIdx = i + 1;
        if (nextIdx < levels.length) {
          nextExp = (levels[nextIdx]['steps'] as int) - threshold;
          currentExp = totalSteps - threshold;
        } else {
          nextExp = 0;
          currentExp = 0;
        }
      } else {
        break;
      }
    }

    return {
      'level': currentLevel,
      'name': levels[currentLevel - 1]['name'] as String,
      'exp': currentExp,
      'nextExp': nextExp,
      'totalSteps': totalSteps,
    };
  }
}
