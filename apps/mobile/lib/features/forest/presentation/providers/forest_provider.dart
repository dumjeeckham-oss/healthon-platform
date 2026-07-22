import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/forest_repository.dart';
import '../../domain/models/forest_summary.dart';

/// ======================================================
/// Forest Repository
/// ======================================================

final forestRepositoryProvider =
    Provider<ForestRepository>((ref) {
  return ForestRepository();
});

/// ======================================================
/// 현재 로그인 사용자
/// ======================================================

final forestUserProvider =
    Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// ======================================================
/// Forest Summary
/// ======================================================

final forestProvider =
    FutureProvider.autoDispose<ForestSummary>((ref) async {

  final user = ref.watch(forestUserProvider);

  if (user == null) {
    return ForestSummary.empty();
  }

  final repository =
      ref.read(forestRepositoryProvider);

  return repository.getSummary(user.id);
});
