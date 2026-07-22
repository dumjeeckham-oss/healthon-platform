import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/forest_summary.dart';

class ForestRepository {
  ForestRepository();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ForestSummary> getSummary(String userId) async {
    final data = await _supabase
        .from('forest_progress')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      return const ForestSummary(
        totalKm: 0,
        treeLevel: 1,
        treeExp: 0,
        nextLevelExp: 100,
        treeName: "새싹",
      );
    }

    final totalKm = (data['total_km'] ?? 0).toDouble();

    final treeLevel = (data['tree_level'] ?? 1) as int;

    final treeExp = (data['tree_exp'] ?? 0).toDouble();

    final nextLevelExp =
        (data['next_level_exp'] ?? 100).toDouble();

    return ForestSummary(
      totalKm: totalKm,
      treeLevel: treeLevel,
      treeExp: treeExp,
      nextLevelExp: nextLevelExp,
      treeName: _treeName(treeLevel),
    );
  }

  Future<void> updateDistance({
    required String userId,
    required double totalKm,
  }) async {
    final level = _calculateLevel(totalKm);

    final exp = totalKm % 100;

    await _supabase.from('forest_progress').upsert({
      'user_id': userId,
      'total_km': totalKm,
      'tree_level': level,
      'tree_exp': exp,
      'next_level_exp': 100,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  int _calculateLevel(double km) {
    return (km ~/ 100) + 1;
  }

  String _treeName(int level) {
    if (level >= 20) return "신비의 숲";
    if (level >= 10) return "거목";
    if (level >= 5) return "큰 나무";
    if (level >= 3) return "나무";
    if (level >= 2) return "묘목";
    return "새싹";
  }
}
