import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/forest_badge.dart';

class ForestBadgeRepository {
  ForestBadgeRepository();

  final SupabaseClient _client = Supabase.instance.client;

  /// ==========================================================
  /// Forest Badge 자동 지급
  /// ==========================================================
  Future<void> checkAndGrantBadges({
    required String userId,
    required double totalKm,
    required int treeLevel,
  }) async {
    final badges = <String>[];

    //----------------------------------------------------------
    // 거리 배지
    //----------------------------------------------------------

    if (totalKm >= 10) badges.add("FIRST_STEP");

    if (totalKm >= 50) badges.add("WALKER");

    if (totalKm >= 100) badges.add("MARATHON");

    if (totalKm >= 300) badges.add("EXPLORER");

    if (totalKm >= 500) badges.add("LEGEND");

    //----------------------------------------------------------
    // 레벨 배지
    //----------------------------------------------------------

    if (treeLevel >= 5) badges.add("TREE_LV5");

    if (treeLevel >= 10) badges.add("TREE_LV10");

    if (treeLevel >= 20) badges.add("TREE_MASTER");

    //----------------------------------------------------------
    // 이미 지급된 배지 확인
    //----------------------------------------------------------

    final granted = await _client
        .from("forest_badges")
        .select("badge.code")
        .eq("user_id", userId);

    final owned = granted
        .map<String>((e) => e["badge.code"] as String)
        .toSet();

    //----------------------------------------------------------
    // 신규 배지만 지급
    //----------------------------------------------------------

    for (final badge in badges) {
      if (owned.contains(badge)) continue;

      await _client.from("forest_badges").insert({
        "user_id": userId,
        "badge.code": badge,
      });
    }
  }

  /// ==========================================================
  /// 내 배지 목록
  /// ==========================================================
  Future<List<ForestBadge>> getMyBadges(String userId) async {
    final result = await _client
        .from("forest_badges")
        .select("badge.code")
        .eq("user_id", userId)
        .order("earned_at");

    return result
    .map<ForestBadge>(
      (e) => ForestBadge.fromMap(e),
    )
    .toList();
  }
}
