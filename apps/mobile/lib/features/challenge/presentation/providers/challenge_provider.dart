import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/challenge_repository.dart';
import '../../domain/models/challenge_summary.dart';

/// Repository
final challengeRepositoryProvider =
    Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});

/// 현재 로그인 사용자
final currentUserIdProvider =
    Provider<String?>((ref) {
  return Supabase.instance.client.auth.currentUser?.id;
});

/// Home Dashboard용 Challenge Provider
final challengeProvider =
    FutureProvider.autoDispose<ChallengeSummary>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return ChallengeSummary.empty();
  }

  final repository =
      ref.read(challengeRepositoryProvider);

  return repository.getSummary(userId);
});
