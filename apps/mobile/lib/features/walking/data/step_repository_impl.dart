import '../../../infra/supabase/supabase_client.dart';

class StepRepositoryImpl {

  final _client = SupabaseClientManager.client;

  /// 오늘 데이터 저장 (UPSERT 방식)
  Future<void> saveDailySteps({
    required String userId,
    required DateTime date,
    required int steps,
    required double distanceKm,
  }) async {

    final formattedDate = DateTime(date.year, date.month, date.day);

    await _client.from('step_daily').upsert({
      'user_id': userId,
      'date': formattedDate.toIso8601String(),
      'steps': steps,
      'distance_km': distanceKm,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,date');
  }

  /// 오늘 데이터 조회
  Future<int> getTodaySteps(String userId) async {

    final today = DateTime.now();
    final formattedDate = DateTime(today.year, today.month, today.day);

    final response = await _client
        .from('step_daily')
        .select('steps')
        .eq('user_id', userId)
        .eq('date', formattedDate.toIso8601String())
        .maybeSingle();

    if (response == null) return 0;

    return response['steps'] ?? 0;
  }
}
