import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/forest_species.dart';

class ForestSpeciesRepository {
  ForestSpeciesRepository();

  final SupabaseClient _client = Supabase.instance.client;

  /// 도감 조회
  Future<List<ForestSpecies>> getSpecies(String userId) async {
    final species = await _client
        .from('forest_species')
        .select()
        .order('level');

    final unlocked = await _client
        .from('user_forest_species')
        .select('species_id')
        .eq('user_id', userId);

    final owned = (unlocked as List)
        .map<String>((e) => e['species_id'].toString())
        .toSet();

    return (species as List).map<ForestSpecies>((e) {
      final id = e['id'].toString();
      return ForestSpecies(
        id: id,
        level: e['level'] as int? ?? 1,
        name: e['name'] as String? ?? '',
        emoji: e['emoji'] as String? ?? '🌱',
        description: e['description'] as String? ?? '',
        image: e['image'] as String? ?? '',
        isUnlocked: owned.contains(id),
      );
    }).toList();
  }

  /// 레벨에 따른 자동 해금
  Future<ForestSpecies?> unlockByLevel({
    required String userId,
    required int level,
  }) async {
    final species = await _client
        .from('forest_species')
        .select()
        .lte('level', level);

    for (final item in (species as List)) {
      final speciesId = item['id'];

      final exists = await _client
          .from('user_forest_species')
          .select('id')
          .eq('user_id', userId)
          .eq('species_id', speciesId)
          .maybeSingle();

      if (exists == null) {
        await _client.from('user_forest_species').insert({
          'user_id': userId,
          'species_id': speciesId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
    return null;
  }

  /// 모든 종 목록
  Future<List<ForestSpecies>> getAllSpecies() async {
    final species = await _client.from('forest_species').select().order('level');
    return (species as List).map<ForestSpecies>((e) {
      return ForestSpecies(
        id: e['id'].toString(),
        level: e['level'] as int? ?? 1,
        name: e['name'] as String? ?? '',
        emoji: e['emoji'] as String? ?? '🌱',
        description: e['description'] as String? ?? '',
        image: e['image'] as String? ?? '',
        isUnlocked: false,
      );
    }).toList();
  }
}
