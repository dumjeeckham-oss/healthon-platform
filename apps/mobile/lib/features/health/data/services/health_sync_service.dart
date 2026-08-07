import 'dart:io' show Platform;


import 'package:health/health.dart';

import '../../domain/models/health_models.dart';

/// ===============================================================
/// HealthON — Health Sync Service
///
/// Health Connect (Android) / Apple Health (iOS) → 데이터 읽기
/// ===============================================================

class HealthSyncService {
  final Health _health = Health();
  HealthDevice? _detectedDevice;

  // =============================================================
  // Device Detection
  // =============================================================

  HealthDevice get detectedDevice {
    if (_detectedDevice != null) return _detectedDevice!;
    if (Platform.isAndroid) {
      _detectedDevice = HealthDevice.healthConnect;
    } else if (Platform.isIOS) {
      _detectedDevice = HealthDevice.appleHealth;
    } else {
      _detectedDevice = HealthDevice.unknown;
    }
    return _detectedDevice!;
  }

  /// 기기에서 Health 데이터 사용 가능 여부
  Future<bool> isAvailable() async {
    try {
      if (Platform.isAndroid) {
        return await _health.isHealthConnectAvailable();
      }
      // iOS는 HealthFactory 생성 시점에 확인
      return true;
    } catch (_) {
      return false;
    }
  }

  // =============================================================
  // 권한 요청
  // =============================================================

  Future<bool> requestAuthorization() async {
    try {
      final types = <HealthDataType>[
        HealthDataType.STEPS,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.EXERCISE_TIME,
      ];

      final permissions = List<HealthDataAccess>.filled(
        types.length,
        HealthDataAccess.READ,
      );

      return await _health.requestAuthorization(types, permissions: permissions);
    } catch (e) {
      print('HealthSyncService.requestAuthorization: $e');
      return false;
    }
  }

  // =============================================================
  // 오늘 데이터 조회
  // =============================================================

  Future<HealthDaily> getTodayData(String userId) async {
    return _getDataForDate(userId, DateTime.now());
  }

  // =============================================================
  // 어제 데이터 조회
  // =============================================================

  Future<HealthDaily> getYesterdayData(String userId) async {
    return _getDataForDate(
      userId,
      DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  // =============================================================
  // 특정 날짜 데이터 조회
  // =============================================================

  Future<HealthDaily> getDataForDate(String userId, DateTime date) async {
    return _getDataForDate(userId, date);
  }

  // =============================================================
  // 기간 조회 (start ~ end, inclusive)
  // =============================================================

  Future<List<HealthDaily>> getDataForRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final List<HealthDaily> results = [];
    final current = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(last)) {
      final daily = await _getDataForDate(userId, current);
      results.add(daily);
      current.add(const Duration(days: 1));
    }

    return results;
  }

  // =============================================================
  // Internal: 특정 날짜 Health 데이터 읽기
  // =============================================================

  Future<HealthDaily> _getDataForDate(String userId, DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    int steps = 0;
    double distanceMeters = 0.0;
    double calories = 0.0;
    int exerciseMinutes = 0;
    int activeMinutes = 0;

    try {
      // 걸음 수
      steps = await _health.getTotalStepsInInterval(dayStart, dayEnd) ?? 0;
    } catch (e) {
      print('HealthSyncService: steps read failed for $date — $e');
    }

    try {
      // 거리 (meters)
      final distData = await _health.getHealthDataFromTypes(
        startTime: dayStart,
        endTime: dayEnd,
        types: [HealthDataType.DISTANCE_DELTA],
      );
      for (final item in distData) {
        distanceMeters += (item.value as NumericHealthValue).numericValue;
      }
    } catch (e) {
      print('HealthSyncService: distance read failed for $date — $e');
    }

    try {
      // 칼로리 (kcal)
      final calData = await _health.getHealthDataFromTypes(
        startTime: dayStart,
        endTime: dayEnd,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      for (final item in calData) {
        calories += (item.value as NumericHealthValue).numericValue;
      }
    } catch (e) {
      print('HealthSyncService: calories read failed for $date — $e');
    }

    try {
      // 운동 시간 (분)
      final exData = await _health.getHealthDataFromTypes(
        startTime: dayStart,
        endTime: dayEnd,
        types: [HealthDataType.EXERCISE_TIME],
      );
      double totalSec = 0;
      for (final item in exData) {
        totalSec += (item.value as NumericHealthValue).numericValue;
      }
      exerciseMinutes = (totalSec / 60).round();
    } catch (e) {
      print('HealthSyncService: exercise time read failed for $date — $e');
    }

    try {
      // 활동 시간 (분) — MOVE_MINUTES not available; skip
      activeMinutes = 0;
    } catch (e) {
      print('HealthSyncService: active minutes read failed for $date — $e');
    }

    return HealthDaily(
      id: '',
      userId: userId,
      date: dayStart,
      steps: steps,
      distanceKm: distanceMeters / 1000.0,
      calories: calories,
      exerciseMinutes: exerciseMinutes,
      activeMinutes: activeMinutes,
      createdAt: DateTime.now(),
    );
  }

  // =============================================================
  // 최근 N일 데이터 (마지막 동기화 이후)
  // =============================================================

  Future<List<HealthDaily>> getDataSinceLastSync(
    String userId,
    DateTime lastSyncDate,
  ) async {
    final start = DateTime(lastSyncDate.year, lastSyncDate.month, lastSyncDate.day);
    final end = DateTime.now();
    if (start.isAfter(end)) return [];
    return getDataForRange(userId, start, end);
  }
}
