import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/challenge_repository.dart';
import '../../domain/challenge_progress.dart';

/// ===============================================================
///
/// Challenge Repository Provider
///
/// ===============================================================

final challengeRepositoryProvider =
    Provider<ChallengeRepository>(
  (ref) => ChallengeRepository(),
);

/// ===============================================================
///
/// Challenge Progress Provider
///
/// Health Connect
///      ↓
/// step_daily
///      ↓
/// ChallengeRepository
///      ↓
/// UI
///
/// ===============================================================

final challengeProvider =
    FutureProvider.autoDispose<ChallengeProgress>((ref) async {
  final repository = ref.read(challengeRepositoryProvider);

  return repository.getProgress();
});

/// ===============================================================
///
/// 총 누적 걸음수
///
/// ===============================================================

final totalStepsProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(challengeRepositoryProvider);

  return repository.getTotalSteps();
});

/// ===============================================================
///
/// 남은 걸음수
///
/// ===============================================================

final remainStepsProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(challengeRepositoryProvider);

  return repository.remainSteps();
});
