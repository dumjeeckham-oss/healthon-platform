import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityRepository {
  ActivityRepository({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// 오늘 활동 저장
  Future<void> saveTodayActivity({
    required String participantId,
    required String profileId,
    required String challengeId,
    required int steps,
    required double distance,
  }) async {
    final today = DateTime.now();

    await _client
        .from('activity_records')
        .upsert({
          'participant_id': participantId,
          'profile_id': profileId,
          'challenge_id': challengeId,
          'activity_date': today.toIso8601String().substring(0, 10),
          'activity_type': 'walking',
          'activity_source': 'health',
          'steps': steps,
          'distance': distance,
        });
  }

  /// 오늘 활동 조회
  Future<Map<String, dynamic>?> getTodayActivity({
    required String participantId,
  }) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final result = await _client
        .from('activity_records')
        .select()
        .eq('participant_id', participantId)
        .eq('activity_date', today)
        .maybeSingle();

    return result;
  }

  /// 총 이동거리
  Future<double> getTotalDistance({
    required String participantId,
  }) async {
    final rows = await _client
        .from('activity_records')
        .select('distance')
        .eq('participant_id', participantId);

    double total = 0;

    for (final row in rows) {
      total += (row['distance'] as num).toDouble();
    }

    return total;
  }

  /// 참가자 정보 업데이트
  Future<void> updateProgress({
    required String participantId,
    required double totalDistance,
    required double goalDistance,
  }) async {
    final percent = (totalDistance / goalDistance * 100).clamp(0, 100);

    await _client
        .from('challenge_participants')
        .update({
          'current_value': totalDistance,
          'goal_percent': percent,
          'last_activity_at': DateTime.now().toIso8601String(),
        })
        .eq('id', participantId);
  }
}
