import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../health/presentation/providers/health_provider.dart';
import '../../data/daily_mission_repository.dart';
import '../../domain/models/daily_mission.dart';

/// Repository
final dailyMissionRepositoryProvider = Provider<DailyMissionRepository>((ref) {
  return DailyMissionRepository();
});

/// 오늘 미션 목록
final dailyMissionProvider = FutureProvider<List<DailyMission>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.read(dailyMissionRepositoryProvider);
  return repository.getTodayMissions(user.id);
});

/// 진행률 새로고침 — health_daily 데이터로 자동 계산
final refreshMissionProvider = FutureProvider.family<List<DailyMission>, MissionProgress>(
  (ref, data) async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final repository = ref.read(dailyMissionRepositoryProvider);

    return repository.refreshProgress(
      userId: user.id,
      totalSteps: data.totalSteps,
      totalKm: data.totalKm,
      forestLevel: data.forestLevel,
      aiVisited: data.aiVisited,
      familyCheers: data.familyCheers,
    );
  },
);

/// 보상 받기
final claimMissionProvider = FutureProvider.family<void, String>((ref, missionId) async {
  final repository = ref.read(dailyMissionRepositoryProvider);
  await repository.claimReward(missionId);
  ref.invalidate(dailyMissionProvider);
});

/// Health 데이터 연동 Mission Progress
final missionProgressFromHealthProvider = FutureProvider<MissionProgress>((ref) async {
  final todayData = await ref.read(healthTodayProvider.future);
  final weekSum = await ref.read(healthWeekProvider.future);

  final totalSteps = todayData?.steps ?? 0;
  final totalKm = weekSum.$2; // total distance from week sum

  // Forest level from total steps
  int forestLevel = 1;
  if (totalSteps >= 200000) { forestLevel = 8; }
  else if (totalSteps >= 120000) { forestLevel = 7; }
  else if (totalSteps >= 80000) { forestLevel = 6; }
  else if (totalSteps >= 50000) { forestLevel = 5; }
  else if (totalSteps >= 30000) { forestLevel = 4; }
  else if (totalSteps >= 15000) { forestLevel = 3; }
  else if (totalSteps >= 5000) { forestLevel = 2; }

  return MissionProgress(
    totalSteps: totalSteps,
    totalKm: totalKm,
    forestLevel: forestLevel,
    aiVisited: false,
    familyCheers: 0,
  );
});

/// Progress Model
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
