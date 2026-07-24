import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/forest_garden_repository.dart';
import '../../domain/models/forest_tile.dart';

/// Repository
final forestGardenRepositoryProvider =
    Provider<ForestGardenRepository>((ref) {
  return ForestGardenRepository();
});

/// Garden Provider
final forestGardenProvider =
    FutureProvider.family<List<ForestTile>, String>(
  (ref, userId) async {
    final repository =
        ref.watch(forestGardenRepositoryProvider);

    return repository.getGarden(userId);
  },
);

/// Garden Controller
class ForestGardenController
    extends StateNotifier<AsyncValue<List<ForestTile>>> {
  ForestGardenController(this._repository)
      : super(const AsyncLoading());

  final ForestGardenRepository _repository;

  Future<void> loadGarden(String userId) async {
    state = const AsyncLoading();

    try {
      final garden =
          await _repository.getGarden(userId);

      state = AsyncData(garden);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> plantTree({
    required String userId,
    required int x,
    required int y,
    required String speciesId,
    required String asset,
  }) async {
    await _repository.plantTree(
      userId: userId,
      x: x,
      y: y,
      speciesId: speciesId,
      asset: asset,
    );

    await loadGarden(userId);
  }

  Future<void> clearTile({
    required String userId,
    required int x,
    required int y,
  }) async {
    await _repository.clearTile(
      userId: userId,
      x: x,
      y: y,
    );

    await loadGarden(userId);
  }

  Future<void> saveGarden({
    required String userId,
    required List<ForestTile> tiles,
  }) async {
    await _repository.saveGarden(
      userId: userId,
      tiles: tiles,
    );

    await loadGarden(userId);
  }
}

/// Controller Provider
final forestGardenControllerProvider =
    StateNotifierProvider<
        ForestGardenController,
        AsyncValue<List<ForestTile>>>(
  (ref) {
    return ForestGardenController(
      ref.watch(forestGardenRepositoryProvider),
    );
  },
);
