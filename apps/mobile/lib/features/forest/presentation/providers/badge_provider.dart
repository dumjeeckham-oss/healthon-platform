import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/forest_badge_repository.dart';

final badgeRepositoryProvider =
    Provider(
  (_) => ForestBadgeRepository(),
);

final badgeProvider =
    FutureProvider((ref) async {

  final user =
      Supabase.instance.client.auth.currentUser;

  if (user == null) {
    return [];
  }

  return ref
      .read(badgeRepositoryProvider)
      .getBadges(user.id);
});
