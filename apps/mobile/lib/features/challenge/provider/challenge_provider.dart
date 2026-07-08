import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/provider/current_user_provider.dart';

import '../data/challenge_repository.dart';
import '../model/challenge_progress.dart';

final challengeProvider =
    FutureProvider<ChallengeProgress>((ref) async {
  final user =
      ref.watch(currentUserProvider);

  if (user == null) {
    return const ChallengeProgress(
      totalSteps: 0,
    );
  }

  final repository = ChallengeRepository();

  return repository.getProgress(user.id);
});
