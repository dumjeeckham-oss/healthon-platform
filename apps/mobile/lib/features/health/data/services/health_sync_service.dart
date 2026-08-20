import 'package:flutter/foundation.dart' show debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart' show TargetPlatform;


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
  bool _configured = false;

  /// Android에서 Health 플러그인 초기화 (deviceId 설정).
  /// Web에서는 호출되지 않는다 (호출부에서 kIsWeb 가드).
  Future<void> _ensureConfigured() async {
    if (_configured) return;

    debugPrint('[DIAG][HEALTH][ANDROID] CONFIGURE_START');
    try {
      await _health.configure();
      _configured = true;
      debugPrint('[DIAG][HEALTH][ANDROID] CONFIGURE_SUCCESS');
    } catch (e) {
      debugPrint('[DIAG][HEALTH][ANDROID] CONFIGURE_ERROR');
      debugPrint('[DIAG][HEALTH][ANDROID] ERROR_TYPE=${e.runtimeType}');
      debugPrint('[DIAG][HEALTH][ANDROID] ERROR_MESSAGE=$e');
      // configure 실패는 치명적이지 않음 — 이후 흐름은 계속 진행
    }
  }

  // =============================================================
  // Device Detection
  // =============================================================

  HealthDevice get detectedDevice {
    if (_detectedDevice != null) return _detectedDevice!;
    if (kIsWeb) {
      // Web: Health 미지원 — 기기 판정 자체를 건너뜀
      _detectedDevice = HealthDevice.unknown;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      _detectedDevice = HealthDevice.healthConnect;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _detectedDevice = HealthDevice.appleHealth;
    } else {
      _detectedDevice = HealthDevice.unknown;
    }
    return _detectedDevice!;
  }

  /// 기기에서 Health 데이터 사용 가능 여부
  Future<bool> isAvailable() async {
    if (kIsWeb) {
      debugPrint('[DIAG][HEALTH][SYNC] PLATFORM=WEB');
      debugPrint('[DIAG][HEALTH][SYNC] SKIPPED_WEB');
      return false;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('[DIAG][HEALTH][ANDROID] AVAILABLE_CHECK');
        final available = await _health.isHealthConnectAvailable();
        debugPrint('[DIAG][HEALTH][ANDROID] AVAILABLE=$available');
        return available;
      }
      // iOS는 HealthFactory 생성 시점에 확인
      return true;
    } catch (e) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('[DIAG][HEALTH][ANDROID] AVAILABLE_ERROR');
        debugPrint('[DIAG][HEALTH][ANDROID] ERROR_TYPE=${e.runtimeType}');
        debugPrint('[DIAG][HEALTH][ANDROID] ERROR_MESSAGE=$e');
      }
      return false;
    }
  }

  // =============================================================
  // 권한 요청
  // =============================================================

  Future<bool> requestAuthorization() async {
    if (kIsWeb) {
      debugPrint('[DIAG][HEALTH][SYNC] PLATFORM=WEB');
      debugPrint('[DIAG][HEALTH][SYNC] SKIPPED_WEB');
      return false;
    }

    try {
      // Android: Health 플러그인 초기화 (deviceId 설정)
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _ensureConfigured();
      }

      // NOTE: EXERCISE_TIME 타입은 health 패키지 13.3.1의 Kotlin mapToType에
      // 없어서 권한 요청이 통째로 실패(AUTH_RESULT=false)한다. 제외하고 요청한다.
      final types = <HealthDataType>[
        HealthDataType.STEPS,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ];

      final permissions = List<HealthDataAccess>.filled(
        types.length,
        HealthDataAccess.READ,
      );

      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('[DIAG][HEALTH][ANDROID] AUTH_START');
      }
      final authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('[DIAG][HEALTH][ANDROID] AUTH_RESULT=$authorized');
      }
      return authorized;
    } catch (e) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('[DIAG][HEALTH][ANDROID] AUTH_ERROR');
        debugPrint('[DIAG][HEALTH][ANDROID] ERROR_TYPE=${e.runtimeType}');
        debugPrint('[DIAG][HEALTH][ANDROID] ERROR_MESSAGE=$e');
      }
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
      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('[DIAG][HEALTH][ANDROID] STEP_READ_START');
      }
      steps = await _health.getTotalStepsInInterval(dayStart, dayEnd) ?? 0;
      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('[DIAG][HEALTH][ANDROID] STEP_READ_END');
        debugPrint('[DIAG][HEALTH][ANDROID] STEP_COUNT=$steps');
      }
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

    // 운동 시간(분): EXERCISE_TIME 타입이 Kotlin mapToType에 없어 Health Connect
    // 권한 요청 자체가 실패하므로 조회를 생략한다. (100K 챌린지는 걸음 수 기반)
    exerciseMinutes = 0;

    try {
      // 활동 시간 (분) — MOVE_MINUTES not available; skip
      activeMinutes = 0;
    } catch (e) {
      print('HealthSyncService: active minutes read failed for $date — $e');
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      debugPrint('[DIAG][HEALTH][ANDROID] SYNC_SUCCESS');
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
