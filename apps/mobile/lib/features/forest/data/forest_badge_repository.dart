import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/forest_badge.dart';

class ForestBadgeRepository {
  final _client = Supabase.instance.client;

  Future<List<ForestBadge>> getBadges(String userId) async {
    final rows = await _client
        .from("forest_badges")
        .select()
        .eq("user_id", userId);

    return rows
        .map<ForestBadge>(
          (e) => ForestBadge.fromMap(e),
        )
        .toList();
  }

  Future<void> earnBadge({
    required String userId,
    required String badgeId,
    required String title,
    required String description,
    required String icon,
  }) async {
    await _client
        .from("forest_badges")
        .upsert({
      "user_id": userId,
      "badge_id": badgeId,
      "title": title,
      "description": description,
      "icon": icon,
      "earned_at": DateTime.now().toIso8601String(),
    });
  }
}
