import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/health_models.dart';
import '../health_mapper.dart';
import 'health_repository_interface.dart';

/// ===============================================================
/// HealthON — SupabaseHealthRepository
///
/// IHealthRepository 의 Supabase 구현체
/// ===============================================================

class SupabaseHealthRepository implements IHealthRepository {
  SupabaseHealthRepository(this._client);

  final SupabaseClient _client;

  static const String _dailyTable = 'health_daily';
  static const String _syncLogTable = 'health_sync_logs';

  // =============================================================
  // Upsert (단일)
  // =============================================================

  @override
  Future<void> upsertDaily(HealthDaily data) async {
    try {
      final result = await _client.rpc('upsert_health_daily', params: {
        'p_user_id': data.userId,
        'p_date': data.date.toIso8601String().substring(0, 10),
        'p_steps': data.steps,
        'p_distance_km': data.distanceKm,
        'p_calories': data.calories,
        'p_exercise_minutes': data.exerciseMinutes,
        'p_active_minutes': data.activeMinutes,
      });

      if (result == null) {
        throw const HealthRepositoryException('upsert_health_daily RPC returned null');
      }
    } catch (e) {
      throw HealthRepositoryException('health_daily upsert 실패: $e', cause: e);
    }
  }

  // =============================================================
  // Upsert (배치)
  // =============================================================

  @override
  Future<void> upsertDailyBatch(List<HealthDaily> dataList) async {
    try {
      for (final data in dataList) {
        await upsertDaily(data);
      }
    } catch (e) {
      throw HealthRepositoryException('health_daily batch upsert 실패: $e', cause: e);
    }
  }

  // =============================================================
  // 오늘 데이터
  // =============================================================

  @override
  Future<HealthDaily?> getToday(String userId) async {
    return getByDate(userId, DateTime.now());
  }

  // =============================================================
  // 특정 날짜 데이터
  // =============================================================

  @override
  Future<HealthDaily?> getByDate(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().substring(0, 10);
      final row = await _client
          .from(_dailyTable)
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();

      if (row == null) return null;

      return HealthDailySupabaseMapper.fromSupabase(row);
    } catch (e) {
      throw HealthRepositoryException('health_daily 조회 실패 (date=$date): $e', cause: e);
    }
  }

  // =============================================================
  // 기간 조회
  // =============================================================

  @override
  Future<List<HealthDaily>> getRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final startStr = start.toIso8601String().substring(0, 10);
      final endStr = end.toIso8601String().substring(0, 10);

      final rows = await _client
          .from(_dailyTable)
          .select()
          .eq('user_id', userId)
          .gte('date', startStr)
          .lte('date', endStr)
          .order('date', ascending: true);

      return (rows as List)
          .map((e) => HealthDailySupabaseMapper.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw HealthRepositoryException('health_daily 기간 조회 실패: $e', cause: e);
    }
  }

  // =============================================================
  // 주간 합계 (RPC)
  // =============================================================

  @override
  Future<(int steps, double distance, double calories)> getWeeklySum(String userId) async {
    try {
      final now = DateTime.now();
      // 이번주 월요일
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final mondayStr = monday.toIso8601String().substring(0, 10);

      final result = await _client.rpc('get_health_weekly', params: {
        'p_user_id': userId,
        'p_start_date': mondayStr,
      });

      if (result == null) return (0, 0.0, 0.0);

      final List data = result is List ? result : [result];
      if (data.isEmpty) return (0, 0.0, 0.0);

      final row = data.first as Map<String, dynamic>;
      return (
        (row['total_steps'] ?? 0) as int,
        (row['total_distance'] as num).toDouble(),
        (row['total_calories'] as num).toDouble(),
      );
    } catch (e) {
      throw HealthRepositoryException('주간 합계 조회 실패: $e', cause: e);
    }
  }

  // =============================================================
  // 월간 합계 (RPC)
  // =============================================================

  @override
  Future<(int steps, double distance, double calories)> getMonthlySum(
    String userId, {
    int? year,
    int? month,
  }) async {
    try {
      final now = DateTime.now();
      final y = year ?? now.year;
      final m = month ?? now.month;

      final result = await _client.rpc('get_health_monthly', params: {
        'p_user_id': userId,
        'p_year': y,
        'p_month': m,
      });

      if (result == null) return (0, 0.0, 0.0);

      final List data = result is List ? result : [result];
      if (data.isEmpty) return (0, 0.0, 0.0);

      final row = data.first as Map<String, dynamic>;
      return (
        (row['total_steps'] ?? 0) as int,
        (row['total_distance'] as num).toDouble(),
        (row['total_calories'] as num).toDouble(),
      );
    } catch (e) {
      throw HealthRepositoryException('월간 합계 조회 실패: $e', cause: e);
    }
  }

  // =============================================================
  // 전체 총합
  // =============================================================

  @override
  Future<(int steps, double distance, double calories)> getTotalSum(String userId) async {
    try {
      final rows = await _client
          .from(_dailyTable)
          .select('steps, distance_km, calories')
          .eq('user_id', userId);

      int totalSteps = 0;
      double totalDist = 0;
      double totalCal = 0;

      for (final row in rows as List) {
        totalSteps += (row['steps'] ?? 0) as int;
        totalDist += _toDouble(row['distance_km']);
        totalCal += _toDouble(row['calories']);
      }

      return (totalSteps, totalDist, totalCal);
    } catch (e) {
      throw HealthRepositoryException('전체 합계 조회 실패: $e', cause: e);
    }
  }

  // =============================================================
  // 마지막 동기화 시각 (health_sync_logs 테이블에서 최근 성공 로그)
  // =============================================================

  @override
  Future<DateTime?> getLastSyncTime(String userId) async {
    try {
      final row = await _client
          .from(_syncLogTable)
          .select('sync_finished')
          .eq('user_id', userId)
          .eq('status', 'success')
          .order('sync_finished', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row == null || row['sync_finished'] == null) return null;

      return DateTime.parse(row['sync_finished']);
    } catch (e) {
      // 첫 동기화면 오류 무시
      return null;
    }
  }

  @override
  Future<void> setLastSyncTime(String userId, DateTime time) async {
    // sync_finished는 sync log에 기록되므로 별도 저장 불필요
  }

  // =============================================================
  // 동기화 로그
  // =============================================================

  @override
  Future<void> logSync(HealthSyncLog log) async {
    try {
      await _client.from(_syncLogTable).insert(log.toSupabase());
    } catch (e) {
      throw HealthRepositoryException('동기화 로그 기록 실패: $e', cause: e);
    }
  }

  @override
  Future<HealthSyncLog?> getLatestSyncLog(String userId) async {
    try {
      final row = await _client
          .from(_syncLogTable)
          .select()
          .eq('user_id', userId)
          .order('sync_started', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row == null) return null;

      return HealthSyncLogSupabaseMapper.fromSupabase(row);
    } catch (e) {
      return null;
    }
  }

  // =============================================================
  // Helpers
  // =============================================================

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return 0.0;
  }

  // =============================================================
  // Walking Provider 호환 메서드
  // =============================================================

  String get _currentUserId => _client.auth.currentUser?.id ?? '';

  @override
  Future<int> getTodaySteps() async {
    final daily = await getToday(_currentUserId);
    return daily?.steps ?? 0;
  }

  @override
  Future<double> estimateDistanceKm() async {
    final steps = await getTodaySteps();
    return steps * 0.0007;
  }

  @override
  Future<double> estimateCalories() async {
    final steps = await getTodaySteps();
    return steps * 0.04;
  }

  @override
  Future<List<int>> getLast7DaysSteps() async {
    final userId = _currentUserId;
    if (userId.isEmpty) return List.filled(7, 0);
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final data = await getRange(userId, start, now);
    final List<int> result = [];
    for (int i = 6; i >= 0; i--) {
      final d = start.add(Duration(days: i));
      final match = data.where((e) =>
          e.date.year == d.year &&
          e.date.month == d.month &&
          e.date.day == d.day).toList();
      result.add(match.isNotEmpty ? match.first.steps : 0);
    }
    return result;
  }

  @override
  Future<int> getWeeklySteps() async {
    final userId = _currentUserId;
    if (userId.isEmpty) return 0;
    final (steps, _, _) = await getWeeklySum(userId);
    return steps;
  }

  @override
  Future<int> getMonthlySteps() async {
    final userId = _currentUserId;
    if (userId.isEmpty) return 0;
    final (steps, _, _) = await getMonthlySum(userId);
    return steps;
  }
}
