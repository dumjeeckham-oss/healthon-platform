import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/forest_tile.dart';

class ForestGardenRepository {
  ForestGardenRepository();

  final SupabaseClient _client = Supabase.instance.client;

  //---------------------------------------------------------
  // 내 숲 조회
  //---------------------------------------------------------

  Future<List<ForestTile>> getGarden(String userId) async {
    final result = await _client
        .from("forest_garden")
        .select()
        .eq("user_id", userId)
        .order("y")
        .order("x");

    if (result.isEmpty) {
      return _createDefaultGarden(userId);
    }

    return (result as List)
        .map((e) => ForestTile.fromMap(e))
        .toList();
  }

  //---------------------------------------------------------
  // 최초 숲 생성 (5x5)
  //---------------------------------------------------------

  Future<List<ForestTile>> _createDefaultGarden(
      String userId) async {
    final tiles = <ForestTile>[];

    for (int y = 0; y < 5; y++) {
      for (int x = 0; x < 5; x++) {
        final tile = ForestTile.empty(x: x, y: y);

        tiles.add(tile);

        await _client.from("forest_garden").insert({
          "user_id": userId,
          ...tile.toMap(),
        });
      }
    }

    return tiles;
  }

  //---------------------------------------------------------
  // 타일 저장
  //---------------------------------------------------------

  Future<void> saveTile({
    required String userId,
    required ForestTile tile,
  }) async {
    await _client.from("forest_garden").upsert({
      "user_id": userId,
      ...tile.toMap(),
    });
  }

  //---------------------------------------------------------
  // 여러 타일 저장
  //---------------------------------------------------------

  Future<void> saveGarden({
    required String userId,
    required List<ForestTile> tiles,
  }) async {
    final rows = tiles
        .map(
          (e) => {
            "user_id": userId,
            ...e.toMap(),
          },
        )
        .toList();

    await _client.from("forest_garden").upsert(rows);
  }

  //---------------------------------------------------------
  // 나무 심기
  //---------------------------------------------------------

  Future<void> plantTree({
    required String userId,
    required int x,
    required int y,
    required String speciesId,
    required String asset,
  }) async {
    await _client
        .from("forest_garden")
        .update({
          "type": ForestTileType.tree.name,
          "object_id": speciesId,
          "asset": asset,
          "planted": true,
          "unlocked": true,
          "level": 1,
          "exp": 0,
          "progress": 0,
          "planted_at":
              DateTime.now().toIso8601String(),
        })
        .eq("user_id", userId)
        .eq("x", x)
        .eq("y", y);
  }

  //---------------------------------------------------------
  // 성장
  //---------------------------------------------------------

  Future<void> updateGrowth({
    required String userId,
    required ForestTile tile,
  }) async {
    await _client
        .from("forest_garden")
        .update({
          "level": tile.level,
          "exp": tile.exp,
          "progress": tile.progress,
        })
        .eq("user_id", userId)
        .eq("x", tile.x)
        .eq("y", tile.y);
  }

  //---------------------------------------------------------
  // 장식 배치
  //---------------------------------------------------------

  Future<void> placeDecoration({
    required String userId,
    required int x,
    required int y,
    required String decorationId,
    required String asset,
  }) async {
    await _client
        .from("forest_garden")
        .update({
          "type": ForestTileType.decoration.name,
          "object_id": decorationId,
          "asset": asset,
        })
        .eq("user_id", userId)
        .eq("x", x)
        .eq("y", y);
  }

  //---------------------------------------------------------
  // 타일 제거
  //---------------------------------------------------------

  Future<void> clearTile({
    required String userId,
    required int x,
    required int y,
  }) async {
    await _client
        .from("forest_garden")
        .update({
          "type": ForestTileType.empty.name,
          "object_id": null,
          "asset": null,
          "planted": false,
          "level": 1,
          "exp": 0,
          "progress": 0,
        })
        .eq("user_id", userId)
        .eq("x", x)
        .eq("y", y);
  }
}
