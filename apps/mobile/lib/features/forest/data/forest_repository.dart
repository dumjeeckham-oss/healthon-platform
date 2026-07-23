import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/forest_summary.dart';
import '../domain/models/forest_badge.dart';

class ForestRepository {
  ForestRepository();

  final SupabaseClient _client = Supabase.instance.client;

  /// ===============================
  /// Forest 조회
  /// ===============================
  Future<ForestSummary> getSummary(String userId) async {
    final data = await _client
        .from('forest_progress')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      return ForestSummary.empty();
    }

    final totalKm =
        (data['total_km'] ?? 0).toDouble();

    return ForestSummary.fromKm(totalKm);
  }

  /// ===============================
  /// Forest 저장
  /// ===============================
  Future<void> updateDistance({
    required String userId,
    required double totalKm,
  }) async {
    final summary =
        ForestSummary.fromKm(totalKm);

    await _client
        .from('forest_progress')
        .upsert({
      'user_id': userId,
      'total_km': totalKm,
      'tree_level': summary.treeLevel,
      'tree_exp': summary.treeExp,
      'next_level_exp': summary.nextLevelExp,
      'updated_at':
          DateTime.now().toIso8601String(),
    });
  }

  /// ===============================
  /// Badge 조회
  /// ===============================
  Future<List<ForestBadge>> getBadges(
      String userId) async {
    final result = await _client
        .from('forest_badges')
        .select()
        .eq('user_id', userId);

    return (result as List)
        .map(
          (e) => ForestBadge.fromMap(e),
        )
        .toList();
  }

  /// ===============================
  /// Badge 저장
  /// ===============================
  Future<void> unlockBadge({
    required String userId,
    required ForestBadge badge,
  }) async {
    await _client
        .from('forest_badges')
        .upsert({
      'user_id': userId,
      'badge_id': badge.id,
      'title': badge.title,
      'description': badge.description,
      'icon': badge.icon,
      'created_at':
          DateTime.now().toIso8601String(),
    });
  }
}
