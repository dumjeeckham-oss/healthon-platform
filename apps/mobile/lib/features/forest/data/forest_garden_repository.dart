import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/forest_tile.dart';

class ForestGardenRepository {
  ForestGardenRepository();

  final SupabaseClient _client = Supabase.instance.client;

  /// 내 숲 조회
  Future<List<ForestTile>> getGarden(String userId) async {
    final result = await _client
        .from('forest_garden')
        .select()
        .eq('user_id', userId)
        .order('pos_y')
        .order('pos_x');

    if ((result as List).isEmpty) {
      return _createDefaultGarden(userId);
    }

    return result.map((e) => ForestTile.fromMap(e)).toList();
  }

  /// 최초 숲 생성 (5x5)
  Future<List<ForestTile>> _createDefaultGarden(String userId) async {
    final tiles = <ForestTile>[];

    for (int y = 0; y < 5; y++) {
      for (int x = 0; x < 5; x++) {
        final tile = ForestTile.empty(x: x, y: y);
        tiles.add(tile);

        await _client.from('forest_garden').insert({
          'user_id': userId,
          'pos_x': tile.x,
          'pos_y': tile.y,
          'species_id': tile.objectId,
          'asset': tile.asset,
          'planted': tile.planted,
          'unlocked': tile.unlocked,
          'level': tile.level,
          'exp': tile.exp,
          'progress': tile.progress,
          'planted_at': tile.plantedAt?.toIso8601String(),
        });
      }
    }

    return tiles;
  }

  /// 타일 저장
  Future<void> saveTile({
    required String userId,
    required ForestTile tile,
  }) async {
    await _client.from('forest_garden').upsert({
      'user_id': userId,
      ...tile.toMap(),
    });
  }

  /// 여러 타일 저장
  Future<void> saveGarden({
    required String userId,
    required List<ForestTile> tiles,
  }) async {
    final rows = tiles.map((e) => {'user_id': userId, ...e.toMap()}).toList();
    await _client.from('forest_garden').upsert(rows);
  }

  /// 나무 심기
  Future<void> plantTree({
    required String userId,
    required int x,
    required int y,
    required String speciesId,
    required String asset,
  }) async {
    await _client
        .from('forest_garden')
        .update({
          'type': ForestTileType.tree.name,
          'species_id': speciesId,
          'asset': asset,
          'planted': true,
          'unlocked': true,
          'level': 1,
          'exp': 0,
          'progress': 0,
          'planted_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('pos_x', x)
        .eq('pos_y', y);
  }

  /// 성장
  Future<void> updateGrowth({
    required String userId,
    required ForestTile tile,
  }) async {
    await _client
        .from('forest_garden')
        .update({
          'level': tile.level,
          'exp': tile.exp,
          'progress': tile.progress,
        })
        .eq('user_id', userId)
        .eq('pos_x', tile.x)
        .eq('pos_y', tile.y);
  }

  /// 장식 배치
  Future<void> placeDecoration({
    required String userId,
    required int x,
    required int y,
    required String decorationId,
    required String asset,
  }) async {
    await _client
        .from('forest_garden')
        .update({
          'type': ForestTileType.decoration.name,
          'object_id': decorationId,
          'asset': asset,
        })
        .eq('user_id', userId)
        .eq('pos_x', x)
        .eq('pos_y', y);
  }

  /// 타일 제거
  Future<void> clearTile({
    required String userId,
    required int x,
    required int y,
  }) async {
    await _client
        .from('forest_garden')
        .update({
          'type': ForestTileType.empty.name,
          'species_id': null,
          'asset': null,
          'planted': false,
          'level': 1,
          'exp': 0,
          'progress': 0,
        })
        .eq('user_id', userId)
        .eq('pos_x', x)
        .eq('pos_y', y);
  }

  /// 레벨별 타일 해금
  Future<void> unlockTileByLevel({
    required String userId,
    required int level,
  }) async {
    // Level 5: 5x5 → 6x6, Level 10: 6x6 → 7x7, etc.
    final size = 5 + (level ~/ 5);
    final existing = await getGarden(userId);
    final existingKeys = existing.map((t) => '${t.x},${t.y}').toSet();

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        if (existingKeys.contains('$x,$y')) continue;
        final tile = ForestTile.empty(x: x, y: y);
        await _client.from('forest_garden').insert({
          'user_id': userId,
          'pos_x': tile.x,
          'pos_y': tile.y,
          'species_id': tile.objectId,
          'asset': tile.asset,
          'planted': tile.planted,
          'unlocked': true,
          'level': tile.level,
          'exp': tile.exp,
          'progress': tile.progress,
          'planted_at': tile.plantedAt?.toIso8601String(),
        });
      }
    }
  }
}
