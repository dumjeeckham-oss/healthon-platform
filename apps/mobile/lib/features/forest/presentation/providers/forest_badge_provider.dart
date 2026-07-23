import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/forest_badge_repository.dart';

final forestBadgeRepositoryProvider =
    Provider((ref) => ForestBadgeRepository());

final forestBadgeProvider =
    FutureProvider.family((ref, String userId) async {
  final repo = ref.read(forestBadgeRepositoryProvider);

  return repo.getMyBadges(userId);
});
