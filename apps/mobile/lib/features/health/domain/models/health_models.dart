/// ===============================================================
/// HealthON — Health Domain Models
///
/// Health Connect / Apple Health → Supabase 동기화
/// ===============================================================

library;

import 'package:flutter/foundation.dart';

// ===============================================================
// HealthDaily — 일별 건강 데이터
// ===============================================================

@immutable
class HealthDaily {
  final String id;
  final String userId;
  final DateTime date;
  final int steps;
  final double distanceKm;
  final double calories;
  final int exerciseMinutes;
  final int activeMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HealthDaily({
    required this.id,
    required this.userId,
    required this.date,
    this.steps = 0,
    this.distanceKm = 0.0,
    this.calories = 0.0,
    this.exerciseMinutes = 0,
    this.activeMinutes = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory HealthDaily.empty() {
    return HealthDaily(
      id: '',
      userId: '',
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// date 부분만 비교 (YYYY-MM-DD)
  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  HealthDaily copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? steps,
    double? distanceKm,
    double? calories,
    int? exerciseMinutes,
    int? activeMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthDaily(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      calories: calories ?? this.calories,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'HealthDaily(date=$dateKey, steps=$steps, distance=${distanceKm}km, calories=$calories)';
}

// ===============================================================
// HealthSyncLog — 동기화 로그
// ===============================================================

@immutable
class HealthSyncLog {
  final String id;
  final String userId;
  final DateTime syncStarted;
  final DateTime? syncFinished;
  final SyncStatus status;
  final HealthDevice device;
  final String? errorMessage;
  final int syncedDays;

  const HealthSyncLog({
    required this.id,
    required this.userId,
    required this.syncStarted,
    this.syncFinished,
    this.status = SyncStatus.pending,
    this.device = HealthDevice.unknown,
    this.errorMessage,
    this.syncedDays = 0,
  });

  HealthSyncLog copyWith({
    String? id,
    String? userId,
    DateTime? syncStarted,
    DateTime? syncFinished,
    SyncStatus? status,
    HealthDevice? device,
    String? errorMessage,
    int? syncedDays,
  }) {
    return HealthSyncLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      syncStarted: syncStarted ?? this.syncStarted,
      syncFinished: syncFinished ?? this.syncFinished,
      status: status ?? this.status,
      device: device ?? this.device,
      errorMessage: errorMessage ?? this.errorMessage,
      syncedDays: syncedDays ?? this.syncedDays,
    );
  }
}

// ===============================================================
// Enums
// ===============================================================

enum SyncStatus {
  pending('대기중'),
  running('동기화 중'),
  success('성공'),
  failed('실패');

  const SyncStatus(this.label);
  final String label;
}

enum HealthDevice {
  unknown('알 수 없음'),
  healthConnect('Android Health Connect'),
  appleHealth('Apple Health');

  const HealthDevice(this.label);
  final String label;
}
