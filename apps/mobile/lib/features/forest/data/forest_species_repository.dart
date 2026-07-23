import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/forest_species.dart';

class ForestSpeciesRepository {
  ForestSpeciesRepository();

  final SupabaseClient _client = Supabase.instance.client;

  /// --------------------------------------------
  /// 도감 조회
  /// --------------------------------------------

  Future<List<ForestSpecies>> getSpecies(
      String userId) async {
    final species = await _client
        .from("forest_species")
        .select()
        .order("level");

    final unlocked = await _client
        .from("user_forest_species")
        .select("species_id")
        .eq("user_id", userId);

    final owned = unlocked
        .map((e) => e["species_id"])
        .toSet();

    return species.map<ForestSpecies>((e) {
      return ForestSpecies(
        id: e["id"].toString(),
        level: e["level"] ?? 1,
        name: e["name"] ?? "",
        emoji: e["emoji"] ?? "🌱",
        description:
            e["description"] ?? "",
        image:
            e["image"] ?? "",
        isUnlocked:
            owned.contains(e["id"]),
      );
    }).toList();
  }

  /// --------------------------------------------
  /// 레벨에 따른 자동 해금
  /// --------------------------------------------

  Future<void> unlockByLevel({
    required String userId,
    required int level,
  }) async {
    final species = await _client
        .from("forest_species")
        .select()
        .lte("level", level);

    for (final item in species) {
      final speciesId = item["id"];

      final exists = await _client
          .from("user_forest_species")
          .select("id")
          .eq("user_id", userId)
          .eq("species_id", speciesId)
          .maybeSingle();

      if (exists == null) {
        await _client
            .from("user_forest_species")
            .insert({
          "user_id": userId,
          "species_id": speciesId,
          "created_at":
              DateTime.now().toIso8601String(),
        });
      }
    }
  }
}
