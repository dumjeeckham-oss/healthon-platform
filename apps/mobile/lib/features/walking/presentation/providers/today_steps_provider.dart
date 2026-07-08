import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/health/step_sync_service.dart';

/// ===============================================================
///
/// Today Steps Provider
///
/// Health Connect
///      ↓
/// Supabase
///      ↓
/// Home UI
///
/// ===============================================================

final todayStepsProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final service = StepSyncService.instance;

  // Health Connect → Supabase 동기화
  await service.syncTodaySteps();

  // 저장된 걸음수 반환
  return service.getTodaySteps();
});
