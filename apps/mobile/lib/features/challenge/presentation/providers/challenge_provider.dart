import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/challenge_repository.dart';
import '../../data/services/challenge_service.dart';

/// Repository
final challengeRepositoryProvider =
    Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});

/// Service
final challengeServiceProvider =
    Provider<ChallengeService>((ref) {
  return ChallengeService(
    ref.read(challengeRepositoryProvider),
  );
});

/// 현재 로그인 사용자
final currentUserIdProvider = Provider<String?>((ref) {
  return Supabase.instance.client.auth.currentUser?.id;
});

/// ======================================================
/// Challenge Dashboard Model
/// ======================================================

class ChallengeDashboard {

  final double totalDistance;

  final double progress;

  final double progressPercent;

  final double remainingDistance;

  final bool completed;

  final int forestLevel;

  final String forestName;

  final String message;

  const ChallengeDashboard({
    required this.totalDistance,
    required this.progress,
    required this.progressPercent,
    required this.remainingDistance,
    required this.completed,
    required this.forestLevel,
    required this.forestName,
    required this.message,
  });
}

/// ======================================================
/// Dashboard Provider
/// ======================================================

final challengeProvider =
    FutureProvider.autoDispose<ChallengeDashboard>((ref) async {

  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    throw Exception("로그인이 필요합니다.");
  }

  final service = ref.read(challengeServiceProvider);

  final total =
      await service.getTotalDistance(userId);

  final progress =
      await service.getProgress(userId);

  final percent =
      await service.getProgressPercent(userId);

  final remain =
      await service.getRemainingDistance(userId);

  final completed =
      await service.isCompleted(userId);

  final level =
      await service.getForestLevel(userId);

  final forest =
      await service.getForestName(userId);

  final message =
      await service.getStatusMessage(userId);

  return ChallengeDashboard(
    totalDistance: total,
    progress: progress,
    progressPercent: percent,
    remainingDistance: remain,
    completed: completed,
    forestLevel: level,
    forestName: forest,
    message: message,
  );
});
