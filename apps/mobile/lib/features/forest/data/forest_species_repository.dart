Future<void> unlockByLevel({
  required String userId,
  required int level,
}) async {
  final result = await _client
      .from('forest_species')
      .select('id')
      .lte('level', level);

  for (final item in result) {
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
}
