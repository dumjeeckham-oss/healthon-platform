import '../domain/models/health_models.dart';

/// ===============================================================
/// HealthON — Health Mapper
///
/// Supabase ↔ Domain Model 변환
/// ===============================================================

// ===============================================================
// HealthDaily ↔ Supabase
// ===============================================================

extension HealthDailySupabaseMapper on HealthDaily {
  static HealthDaily fromSupabase(Map<String, dynamic> row) {
    return HealthDaily(
      id: row['id'] ?? '',
      userId: row['user_id'] ?? '',
      date: row['date'] != null ? DateTime.parse(row['date'].toString()) : DateTime.now(),
      steps: (row['steps'] ?? 0) as int,
      distanceKm: (_toDouble(row['distance_km'])),
      calories: (_toDouble(row['calories'])),
      exerciseMinutes: (row['exercise_minutes'] ?? 0) as int,
      activeMinutes: (row['active_minutes'] ?? 0) as int,
      createdAt: _parseTs(row['created_at']),
      updatedAt: row['updated_at'] != null ? _parseTs(row['updated_at']) : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'date': date.toIso8601String().substring(0, 10), // YYYY-MM-DD
      'steps': steps,
      'distance_km': distanceKm,
      'calories': calories,
      'exercise_minutes': exerciseMinutes,
      'active_minutes': activeMinutes,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static DateTime _parseTs(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is String) return DateTime.parse(v);
    if (v is DateTime) return v;
    return DateTime.now();
  }
}

// ===============================================================
// HealthSyncLog ↔ Supabase
// ===============================================================

extension HealthSyncLogSupabaseMapper on HealthSyncLog {
  static HealthSyncLog fromSupabase(Map<String, dynamic> row) {
    return HealthSyncLog(
      id: row['id'] ?? '',
      userId: row['user_id'] ?? '',
      syncStarted: row['sync_started'] != null ? DateTime.parse(row['sync_started']) : DateTime.now(),
      syncFinished: row['sync_finished'] != null ? DateTime.parse(row['sync_finished']) : null,
      status: _parseSyncStatus(row['status']),
      device: _parseDevice(row['device']),
      errorMessage: row['error_message'],
      syncedDays: (row['synced_days'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'user_id': userId,
      'sync_started': syncStarted.toUtc().toIso8601String(),
      if (syncFinished != null) 'sync_finished': syncFinished!.toUtc().toIso8601String(),
      'status': status.name,
      'device': device.name,
      'synced_days': syncedDays,
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }

  static SyncStatus _parseSyncStatus(dynamic v) {
    switch (v) {
      case 'running': return SyncStatus.running;
      case 'success': return SyncStatus.success;
      case 'failed': return SyncStatus.failed;
      default: return SyncStatus.pending;
    }
  }

  static HealthDevice _parseDevice(dynamic v) {
    switch (v) {
      case 'health_connect': return HealthDevice.healthConnect;
      case 'apple_health': return HealthDevice.appleHealth;
      default: return HealthDevice.unknown;
    }
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return 0.0;
}
