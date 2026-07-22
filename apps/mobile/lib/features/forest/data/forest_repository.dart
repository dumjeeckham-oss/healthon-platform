import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/forest_summary.dart';

class ForestRepository {
  ForestRepository();

  final _client = Supabase.instance.client;

  Future<ForestSummary> getSummary(String userId) async {
    final result = await _client
        .from('forest_progress')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (result == null) {
      return ForestSummary.empty();
    }

    return ForestSummary.fromMap(result);
  }

 Future<void> updateDistance({
  required String userId,
  required double totalKm,
}) async {

  final summary = _calculateLevel(totalKm);

  await _client
      .from('forest_progress')
      .upsert({

        'user_id': userId,

        'total_km': totalKm,

        'tree_level': summary.treeLevel,

        'tree_exp': summary.treeExp,

        'next_level_exp': summary.nextLevelExp,

        'updated_at': DateTime.now().toIso8601String(),

      });

}
