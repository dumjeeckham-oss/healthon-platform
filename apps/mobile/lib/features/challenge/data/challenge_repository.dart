import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/challenge_progress.dart';

class ChallengeRepository {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<ChallengeProgress> getProgress(
      String userId) async {
    final rows = await _supabase
        .from('step_daily')
        .select('steps')
        .eq('user_id', userId);

    int total = 0;

    for (final row in rows) {
      total += (row['steps'] ?? 0) as int;
    }

    return ChallengeProgress(
      totalSteps: total,
    );
  }
}
