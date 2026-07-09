import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'health_service.dart';

/// ===============================================================
///
/// Step Sync Service
///
/// Health Connect / Apple Health
///
/// ↓
///
/// Supabase step_daily 동기화
///
/// ===============================================================
class StepSyncService {
  StepSyncService._();

  static final StepSyncService instance = StepSyncService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// --------------------------------------------------------------
  /// 오늘 걸음수 동기화
  /// --------------------------------------------------------------
  Future<void> syncTodaySteps() async {
    final authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      return;
    }

    final steps =
        await HealthService.instance.getTodaySteps();

    final today = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());

    await _supabase
        .from('step_daily')
        .upsert(
          {
            'user_id': authUser.id,
            'date': today,
            'steps': steps,
            'updated_at':
                DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id,date',
        );
  }

  /// --------------------------------------------------------------
  /// 오늘 걸음수 조회
  /// --------------------------------------------------------------
  Future<int> getTodaySteps() async {
    final authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      return 0;
    }

    final today = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());

    final response = await _supabase
        .from('step_daily')
        .select('steps')
        .eq('user_id', authUser.id)
        .eq('date', today)
        .maybeSingle();

    if (response == null) {
      return 0;
    }

    return response['steps'] ?? 0;
  }

  /// --------------------------------------------------------------
  /// 강제 동기화
  /// --------------------------------------------------------------
  Future<int> refresh() async {
    await syncTodaySteps();

    return getTodaySteps();
  }
}
