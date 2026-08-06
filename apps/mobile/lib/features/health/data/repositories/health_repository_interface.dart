import '../domain/models/health_models.dart';

/// ===============================================================
/// HealthON — IHealthRepository
///
/// Health 데이터 저장/조회 인터페이스
/// ===============================================================

abstract class IHealthRepository {
  // ── 저장 ──

  /// 일별 건강 데이터 Upsert (중복 방지)
  Future<void> upsertDaily(HealthDaily data);

  /// 여러 날 일괄 Upsert
  Future<void> upsertDailyBatch(List<HealthDaily> dataList);

  // ── 조회 ──

  /// 오늘 데이터
  Future<HealthDaily?> getToday(String userId);

  /// 특정 날짜 데이터
  Future<HealthDaily?> getByDate(String userId, DateTime date);

  /// 기간 조회
  Future<List<HealthDaily>> getRange(String userId, DateTime start, DateTime end);

  /// 주간 합계
  Future<(int steps, double distance, double calories)> getWeeklySum(String userId);

  /// 월간 합계
  Future<(int steps, double distance, double calories)> getMonthlySum(String userId, {int? year, int? month});

  /// 전체 기간 총합
  Future<(int steps, double distance, double calories)> getTotalSum(String userId);

  // ── 동기화 ──

  /// 마지막 동기화 시각 조회
  Future<DateTime?> getLastSyncTime(String userId);

  /// 마지막 동기화 시각 저장
  Future<void> setLastSyncTime(String userId, DateTime time);

  /// 동기화 로그 기록
  Future<void> logSync(HealthSyncLog log);

  /// 최근 동기화 로그 조회
  Future<HealthSyncLog?> getLatestSyncLog(String userId);
}

// ===============================================================
// Health Repository Exception
// ===============================================================

class HealthRepositoryException implements Exception {
  final String message;
  final Object? cause;

  const HealthRepositoryException(this.message, {this.cause});

  @override
  String toString() => 'HealthRepositoryException: $message';
}
