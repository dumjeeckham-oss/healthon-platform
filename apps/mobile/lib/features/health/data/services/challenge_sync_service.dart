/// ===============================================================
/// HealthON — Challenge Sync Service (v2 — Social Engine 연동)
///
/// health_daily 거리 합계 → challenge_progress 자동 계산
/// Challenge 이정표 도달/완료 시 ActivityEvent 자동 발생
/// ===============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../social_engine/activity_engine.dart';
import '../../../social_engine/activity_models.dart';

class ChallengeSyncService {
  final SupabaseClient _client;

  ChallengeSyncService(this._client);

  /// health_daily.distance_km 합계 → challenge_progress 업데이트
  Future<Map<String, Object>?> syncChallengeFromHealth(String userId) async {
    // 1. health_daily 전체 distance_km 합계
    final result = await _client
        .from('health_daily')
        .select('distance_km')
        .eq('user_id', userId);

    double totalKm = 0;
    for (final row in result as List) {
      totalKm += (row['distance_km'] ?? 0).toDouble();
    }

    final progress = (totalKm / 100).clamp(0.0, 1.0);
    final bool completed = totalKm >= 100;

    // 2. 이전 진행률 조회
    final oldProgress = await _client
        .from('challenge_progress')
        .select('progress, completed')
        .eq('user_id', userId)
        .maybeSingle();

    final double oldProgressVal = (oldProgress?['progress'] ?? 0.0).toDouble();
    final bool wasCompleted = oldProgress?['completed'] ?? false;

    // 3. challenge_progress 업데이트
    await _client.from('challenge_progress').upsert({
      'user_id': userId,
      'total_distance': totalKm,
      'progress': progress,
      'completed': completed,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    // 4. Social Engine 이벤트 발생
    final engine = ActivityEngine(_client);

    // 완료 이벤트
    if (completed && !wasCompleted) {
      try {
        await engine.emitChallengeCompleted(
          userId: userId,
          challengeName: '100K Challenge',
          totalKm: totalKm,
        );
      } catch (e) {
        print('ChallengeSync: completed event failed — $e');
      }
    }

    // 이정표 이벤트 (25%, 50%, 75% 도달)
    for (final milestone in [0.25, 0.5, 0.75]) {
      if (progress >= milestone && oldProgressVal < milestone) {
        try {
          await engine.emitChallengeMilestone(
            userId: userId,
            challengeName: '100K Challenge',
            progress: progress,
            totalKm: totalKm,
          );
        } catch (e) {
          print('ChallengeSync: milestone event failed — $e');
        }
      }
    }

    return {
      'totalKm': totalKm,
      'progress': progress,
      'completed': completed,
      'wasCompleted': wasCompleted,
    };
  }
}
