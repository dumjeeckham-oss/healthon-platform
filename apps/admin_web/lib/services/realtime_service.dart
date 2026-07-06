import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  final supabase = Supabase.instance.client;

  /// 안정형 KPI 스트림 (실무용)
  Stream<Map<String, dynamic>> streamStats() {
    return supabase
        .from('step_daily')
        .stream(primaryKey: ['id'])
        .map((data) {
      final Map<String, int> userSteps = {};

      for (final row in data) {
        final userId = row['user_id'];
        final steps = row['steps'] ?? 0;

        userSteps[userId] = (userSteps[userId] ?? 0) + steps;
      }

      final totalUsers = userSteps.keys.length;
      final totalSteps =
          userSteps.values.fold(0, (a, b) => a + b);

      final activeUsers =
          userSteps.values.where((s) => s > 1000).length;

      final activeRate =
          totalUsers == 0 ? 0.0 : activeUsers / totalUsers;

      return {
        "totalUsers": totalUsers,
        "activeUsers": activeUsers,
        "totalSteps": totalSteps,
        "activeRate": activeRate,
      };
    });
  }
}