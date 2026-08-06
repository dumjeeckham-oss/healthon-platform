/// ===============================================================
/// HealthON — Challenge Sync Service
///
/// health_daily 거리 합계 → challenge_progress 자동 계산
/// ===============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeSyncService {
  final SupabaseClient _client;

  ChallengeSyncService(this._client);

  /// health_daily.distance_km 합계 → challenge_progress 업데이트
  Future<void> syncChallengeFromHealth(String userId) async {
    // 1. health_daily 전체 distance_km 합계
    final result = await _client
        .from('health_daily')
        .select('distance_km')
        .eq('user_id', userId);

    double totalKm = 0;
    for (final row in result as List) {
      totalKm += (row['distance_km'] ?? 0).toDouble();
    }

    // 2. challenge_progress 업데이트
    final bool completed = totalKm >= 100;

    await _client.from('challenge_progress').upsert({
      'user_id': userId,
      'total_distance': totalKm,
      'progress': (totalKm / 100).clamp(0.0, 1.0),
      'completed': completed,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
