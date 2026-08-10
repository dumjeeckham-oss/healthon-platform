import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/connectivity_service.dart';
import 'local_health_cache.dart';
import '../../domain/models/health_models.dart';

/// ===============================================================
/// HealthON — Offline-Aware Sync Service
///
/// 연결 상태 감지 → 오프라인 시 로컬 SQLite 저장
/// 온라인 복귀 시 자동 Supabase 업로드
/// ===============================================================

class OfflineAwareSyncService {
  static final OfflineAwareSyncService _instance =
      OfflineAwareSyncService._();

  factory OfflineAwareSyncService() => _instance;

  OfflineAwareSyncService._();

  final LocalHealthCache _cache = LocalHealthCache();
  StreamSubscription? _connectivitySub;
  bool _initialized = false;

  static const int _maxRetryAttempts = 5;

  /// 초기화 — connectivity 스트림 구독
  void init() {
    if (_initialized) return;

    if (kIsWeb) {
      debugPrint(
        '🌐 Web — OfflineAwareSyncService disabled',
      );
      _initialized = true;
      return;
    }

    _connectivitySub = ConnectivityService.stream.listen((status) {
      if (status == NetworkStatus.connected) {
        debugPrint('🌐 Online — flushing pending health data');
        _flushPending();
      }
    });

    _initialized = true;

    // 온라인이면 바로 flush
    if (ConnectivityService.isConnected) {
      _flushPending();
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  // =============================================================
  // 오프라인 저장
  // =============================================================

  Future<void> saveOffline(HealthDaily data) async {
    await _cache.savePending(data);
    final count = await _cache.pendingCount();
    debugPrint('📦 Saved to local cache (pending: $count)');
  }

  // =============================================================
  // 미전송 데이터 Supabase로 bulk upload
  // =============================================================

  Future<int> _flushPending() async {
    if (kIsWeb) {
      return 0;
    }

    final pending = await _cache.getPending();
    if (pending.isEmpty) return 0;

    debugPrint('📤 Flushing ${pending.length} pending health records');

    int uploaded = 0;

    for (final data in pending) {
      try {
        // IHealthRepository 직접 참조는 순환 의존 유발 가능 → SupabaseClient 직접 사용
        final supabase = Supabase.instance.client;
        final userId = data.userId;
        final dateStr = data.date.toIso8601String().substring(0, 10);

        await supabase.rpc('upsert_health_daily', params: {
          'p_user_id': userId,
          'p_date': dateStr,
          'p_steps': data.steps,
          'p_distance_km': data.distanceKm,
          'p_calories': data.calories,
          'p_exercise_minutes': data.exerciseMinutes,
          'p_active_minutes': data.activeMinutes,
        });

        // 업로드 성공 → 캐시 삭제
        await _cache.removePending(userId, data.date);
        uploaded++;
      } catch (e) {
        // 실패 → 재시도 횟수 증가
        await _cache.incrementAttempts(data.userId, data.date);

        final attempts = await _cache.getAttempts(data.userId, data.date);
        if (attempts >= _maxRetryAttempts) {
          debugPrint('❌ Max retries exceeded for ${data.dateKey} — removing');
          await _cache.removePending(data.userId, data.date);
        } else {
          debugPrint('❌ Upload failed for ${data.dateKey} (attempt $attempts) — retry later');
        }
      }
    }

    final remaining = await _cache.pendingCount();
    debugPrint('📤 Flush complete: uploaded=$uploaded remaining=$remaining');
    return uploaded;
  }

  /// 수동 flush (RefreshIndicator 등에서 호출)
  Future<int> flushNow() => _flushPending();

  /// 미전송 개수
  Future<int> pendingCount() async {
    if (kIsWeb) {
      return 0;
    }

    return _cache.pendingCount();
  }
}
