import 'package:supabase_flutter/supabase_flutter.dart';

import 'health_service.dart';

class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final _supabase = Supabase.instance.client;

  /// 오늘 활동 동기화
  Future<void> syncTodayActivity({
    required String profileId,
    required String challengeId,
    required String participantId,
  }) async {
    final steps = await HealthService.instance.getTodaySteps();

    final distance = await HealthService.instance.getTodayDistance();

    final today = DateTime.now();

    await _supabase
        .from('activity_records')
        .upsert({
          "participant_id": participantId,
          "profile_id": profileId,
          "challenge_id": challengeId,
          "activity_date":
              today.toIso8601String().substring(0, 10),
          "activity_type": "walking",
          "activity_source": "health",
          "steps": steps,
          "distance": distance,
        });

    await _updateParticipant(
      participantId,
      challengeId,
    );
  }

  Future<void> _updateParticipant(
    String participantId,
    String challengeId,
  ) async {
    final records = await _supabase
        .from('activity_records')
        .select("distance")
        .eq("participant_id", participantId);

    double totalDistance = 0;

    for (final row in records) {
      totalDistance +=
          (row["distance"] as num).toDouble();
    }

    await _supabase
        .from("challenge_participants")
        .update({
          "current_value": totalDistance,
          "goal_percent":
              (totalDistance / 100) * 100,
        })
        .eq("id", participantId);
  }
}
