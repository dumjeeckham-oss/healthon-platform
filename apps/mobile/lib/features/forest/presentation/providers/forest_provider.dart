import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/forest_repository.dart';
import '../../domain/models/forest_summary.dart';

/// Repository
final forestRepositoryProvider =
    Provider<ForestRepository>((ref) {
  return ForestRepository();
});

/// 현재 로그인 사용자
final forestUserIdProvider =
    Provider<String?>((ref) {
  return Supabase.instance.client.auth.currentUser?.id;
});

/// Forest Dashboard
final forestProvider =
    FutureProvider.autoDispose<ForestSummary>((ref) async {
  final user =
       ref.watch(forestUserIdProvider);

  if (userId == null) {
    return ForestSummary.empty();
  }
      

  final repository =
      ref.read(forestRepositoryProvider);

  return repository.getSummary(userId);
});
