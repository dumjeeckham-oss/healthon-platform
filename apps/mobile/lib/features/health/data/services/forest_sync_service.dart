/// ===============================================================
/// HealthON — Forest Sync Service
///
/// health_daily.steps 합계 → Forest tree 성장률 자동 연동
/// ===============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

class ForestSyncService {
  final SupabaseClient _client;

  ForestSyncService(this._client);

  /// 걸음 → 거리 환산 (평균 보폭 0.7m)
  double stepsToKm(int steps) => (steps * 0.7) / 1000.0;

  /// health_daily.steps 총합 → forest_progress 업데이트
  ///
  /// 예)
  ///   5,000걸음 → 3.5km → Water 단계
  ///  10,000걸음 → 7.0km → Growth 단계
  ///  30,000걸음 → 21.0km → Tree Level 상승
  Future<void> syncForestFromHealth(String userId) async {
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

    // 2. forest_progress 업데이트
    final forest = await _getForestLevel(totalKm);

    await _client.from('forest_progress').upsert({
      'user_id': userId,
      'total_km': totalKm,
      'total_steps': totalSteps,
      'tree_level': forest['level'],
      'tree_exp': forest['exp'],
      'next_level_exp': forest['nextExp'],
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// 걸음 누적 기반 Forest 레벨/경험치 계산
  ///
  /// 레벨 테이블 (걸음 기준):
  ///   Lv.1 새싹       0 ~ 5,000걸음
  ///   Lv.2 묘목       5,000 ~ 15,000
  ///   Lv.3 어린나무   15,000 ~ 30,000
  ///   Lv.4 성장나무   30,000 ~ 50,000
  ///   Lv.5 큰나무     50,000 ~ 80,000
  ///   Lv.6 숲         80,000 ~ 120,000
  ///   Lv.7 울창한숲   120,000 ~ 200,000
  ///   Lv.8 열대우림   200,000+
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
      'exp': currentExp,
      'nextExp': nextExp,
      'totalSteps': totalSteps,
    };
  }
}
