import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../data/daily_mission_repository.dart';
import '../../domain/models/daily_mission.dart';

/// ===============================================================
/// Repository
/// ===============================================================

final dailyMissionRepositoryProvider =
    Provider<DailyMissionRepository>((ref) {
  return DailyMissionRepository();
});

/// ===============================================================
/// 오늘 미션
/// ===============================================================

final dailyMissionProvider =
    FutureProvider<List<DailyMission>>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return [];
  }

  final repository =
      ref.read(dailyMissionRepositoryProvider);

  return repository.getTodayMissions(user.id);
});

/// ===============================================================
/// 진행률 새로고침
/// ===============================================================

final refreshMissionProvider =
    FutureProvider.family<List<DailyMission>, MissionProgress>(
        (ref, data) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return [];
  }

  final repository =
      ref.read(dailyMissionRepositoryProvider);

  return repository.refreshProgress(
    userId: user.id,
    totalSteps: data.totalSteps,
    totalKm: data.totalKm,
    forestLevel: data.forestLevel,
    aiVisited: data.aiVisited,
    familyCheers: data.familyCheers,
  );
});

/// ===============================================================
/// 보상 받기
/// ===============================================================

final claimMissionProvider =
    FutureProvider.family<void, String>((ref, missionId) async {
  final repository =
      ref.read(dailyMissionRepositoryProvider);

  await repository.claimReward(missionId);

  ref.invalidate(dailyMissionProvider);
});

/// ===============================================================
/// Progress Model
/// ===============================================================

class MissionProgress {
  final int totalSteps;

  final double totalKm;

  final int forestLevel;

  final bool aiVisited;

  final int familyCheers;

  const MissionProgress({
    required this.totalSteps,
    required this.totalKm,
    required this.forestLevel,
    required this.aiVisited,
    required this.familyCheers,
  });
}
