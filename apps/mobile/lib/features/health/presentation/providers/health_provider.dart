/// ===============================================================
/// HealthON — Health Providers (최종 통합)
///
/// 기존 health_provider.dart 를 대체합니다.
/// 모든 기존 메서드 시그니처를 유지하면서 신규 Repository 기반으로 동작합니다.
/// ===============================================================

library;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/health_models.dart';
import '../../data/services/health_sync_service.dart';
import '../../data/services/post_sync_orchestrator.dart';
import '../../data/repositories/health_repository_interface.dart';
import '../../data/repositories/supabase_health_repository.dart';

// ===============================================================
// Supabase Client
// ===============================================================

final healthSupabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ===============================================================
// Health Sync Service (device level)
// ===============================================================

final healthSyncServiceProvider = Provider<HealthSyncService>(
  (ref) => HealthSyncService(),
);

// ===============================================================
// Repository
// ===============================================================

final healthRepositoryProvider = Provider<IHealthRepository>(
  (ref) => SupabaseHealthRepository(ref.watch(healthSupabaseProvider)),
);

// ===============================================================
// 권한 Provider
// ===============================================================

final healthPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(healthSyncServiceProvider);

  final available = await service.isAvailable();
  if (!available) return false;

  return service.requestAuthorization();
});

// ===============================================================
// 오늘 데이터 Provider
// ===============================================================

final healthTodayProvider = FutureProvider<HealthDaily?>((ref) async {
  try {
    final repo = ref.watch(healthRepositoryProvider);
    final client = ref.watch(healthSupabaseProvider);
    final user = client.auth.currentUser;

    if (user == null) return null;

    return repo.getToday(user.id);
  } catch (e) {
    print('healthTodayProvider: $e');
    return null;
  }
});

// ===============================================================
// 오늘 걸음수 Provider (기존 호환)
// ===============================================================

final todayStepsProvider = FutureProvider<int>((ref) async {
  final daily = await ref.watch(healthTodayProvider.future);
  return daily?.steps ?? 0;
});

// ===============================================================
// 오늘 거리 Provider (기존 호환)
// ===============================================================

final todayDistanceProvider = FutureProvider<double>((ref) async {
  final daily = await ref.watch(healthTodayProvider.future);
  return daily?.distanceKm ?? 0.0;
});

// ===============================================================
// 오늘 칼로리 Provider (기존 호환)
// ===============================================================

final todayCaloriesProvider = FutureProvider<double>((ref) async {
  final daily = await ref.watch(healthTodayProvider.future);
  return daily?.calories ?? 0.0;
});

// ===============================================================
// 최근 7일 걸음수 Provider (기존 호환)
// ===============================================================

final weeklyStepsProvider = FutureProvider<List<int>>((ref) async {
  try {
    final repo = ref.watch(healthRepositoryProvider);
    final client = ref.watch(healthSupabaseProvider);
    final user = client.auth.currentUser;

    if (user == null) return [];

    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final data = await repo.getRange(user.id, start, now);

    final List<int> result = [];
    for (int i = 6; i >= 0; i--) {
      final d = start.add(Duration(days: i));
      final match = data.where((e) =>
        e.date.year == d.year &&
        e.date.month == d.month &&
        e.date.day == d.day
      ).toList();
      result.add(match.isNotEmpty ? match.first.steps : 0);
    }

    return result;
  } catch (e) {
    print('weeklyStepsProvider: $e');
    return List.filled(7, 0);
  }
});

// ===============================================================
// 주간 합계 Provider
// ===============================================================

final healthWeekProvider = FutureProvider<(int steps, double distance, double calories)>((ref) async {
  try {
    final repo = ref.watch(healthRepositoryProvider);
    final client = ref.watch(healthSupabaseProvider);
    final user = client.auth.currentUser;

    if (user == null) return (0, 0.0, 0.0);

    return repo.getWeeklySum(user.id);
  } catch (e) {
    print('healthWeekProvider: $e');
    return (0, 0.0, 0.0);
  }
});

// ===============================================================
// 월간 합계 Provider
// ===============================================================

final healthMonthProvider = FutureProvider<(int steps, double distance, double calories)>((ref) async {
  try {
    final repo = ref.watch(healthRepositoryProvider);
    final client = ref.watch(healthSupabaseProvider);
    final user = client.auth.currentUser;

    if (user == null) return (0, 0.0, 0.0);

    return repo.getMonthlySum(user.id);
  } catch (e) {
    print('healthMonthProvider: $e');
    return (0, 0.0, 0.0);
  }
});

// ===============================================================
// 동기화 Provider
// ===============================================================

enum HealthSyncState { idle, syncing, success, failed }

class HealthSyncStatus {
  final HealthSyncState state;
  final String? errorMessage;

  const HealthSyncStatus({
    this.state = HealthSyncState.idle,
    this.errorMessage,
  });
}

class HealthSyncNotifier extends StateNotifier<HealthSyncStatus> {
  HealthSyncNotifier(this._repo, this._service) : super(const HealthSyncStatus());

  final IHealthRepository _repo;
  final HealthSyncService _service;

  Future<bool> sync() async {
    if (kIsWeb) {
      // Web: Health Sync 미지원 — 정상 종료 (예외/실패 로그 없음)
      debugPrint('[DIAG][HEALTH][SYNC] PLATFORM=WEB');
      debugPrint('[DIAG][HEALTH][SYNC] SKIPPED_WEB');
      state = const HealthSyncStatus(state: HealthSyncState.success);
      return true;
    }

    state = const HealthSyncStatus(state: HealthSyncState.syncing);

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        state = const HealthSyncStatus(state: HealthSyncState.failed, errorMessage: '로그인이 필요합니다');
        return false;
      }

      final userId = currentUser.id;

      final authorized = await _service.requestAuthorization();
      if (!authorized) {
        state = const HealthSyncStatus(state: HealthSyncState.failed, errorMessage: 'Health 권한이 필요합니다');
        return false;
      }

      final logStart = HealthSyncLog(
        id: '',
        userId: userId,
        syncStarted: DateTime.now(),
        status: SyncStatus.running,
        device: _service.detectedDevice,
      );
      await _repo.logSync(logStart);

      // 데이터 조회
      final todayData = await _service.getTodayData(userId);
      final yesterdayData = await _service.getYesterdayData(userId);

      final lastSync = await _repo.getLastSyncTime(userId);
      final startDate = lastSync ?? DateTime.now().subtract(const Duration(days: 7));
      final rangeData = await _service.getDataForRange(
        userId,
        startDate,
        DateTime.now().subtract(const Duration(days: 1)),
      );

      final List<HealthDaily> toSync = [];
      if (yesterdayData.steps > 0) toSync.add(yesterdayData);
      if (todayData.steps > 0) toSync.add(todayData);
      for (final d in rangeData) {
        if (d.steps > 0) toSync.add(d);
      }

      // 중복 제거
      final Map<String, HealthDaily> deduped = {};
      for (final d in toSync) {
        deduped[d.dateKey] = d;
      }

      if (deduped.isNotEmpty) {
        await _repo.upsertDailyBatch(deduped.values.toList());
      }

      // Post-Sync 연쇄 작업
      try {
        final orchestrator = PostSyncOrchestrator(supabase);
        await orchestrator.runAll(userId);
      } catch (e) {
        print('PostSyncOrchestrator: $e');
      }

      final logFinish = HealthSyncLog(
        id: '',
        userId: userId,
        syncStarted: DateTime.now(),
        syncFinished: DateTime.now(),
        status: SyncStatus.success,
        device: _service.detectedDevice,
        syncedDays: deduped.length,
      );
      await _repo.logSync(logFinish);

      state = const HealthSyncStatus(state: HealthSyncState.success);
      return true;
    } catch (e) {
      state = HealthSyncStatus(state: HealthSyncState.failed, errorMessage: e.toString());

      try {
        final supabase = Supabase.instance.client;
        final currentUser = supabase.auth.currentUser;
        if (currentUser != null) {
          await _repo.logSync(HealthSyncLog(
            id: '',
            userId: currentUser.id,
            syncStarted: DateTime.now(),
            syncFinished: DateTime.now(),
            status: SyncStatus.failed,
            device: _service.detectedDevice,
            errorMessage: e.toString(),
          ));
        }
      } catch (_) {}

      return false;
    }
  }
}

final healthSyncProvider =
    StateNotifierProvider<HealthSyncNotifier, HealthSyncStatus>(
  (ref) => HealthSyncNotifier(
    ref.watch(healthRepositoryProvider),
    ref.watch(healthSyncServiceProvider),
  ),
);
