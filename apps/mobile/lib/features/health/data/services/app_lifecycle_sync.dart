import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../health/presentation/providers/health_provider.dart';
import '../../health/data/services/post_sync_orchestrator.dart';
import '../../../social_engine/activity_dispatcher.dart';

/// ===============================================================
/// HealthON — App Lifecycle Sync Service
///
/// 앱 Resume 시 + 주기적(오전 6시) Health 데이터 동기화
/// ===============================================================

class AppLifecycleSync extends WidgetsBindingObserver {
  static final AppLifecycleSync _instance = AppLifecycleSync._();

  factory AppLifecycleSync() => _instance;

  AppLifecycleSync._();

  bool _initialized = false;
  bool _syncing = false;
  Timer? _periodicTimer;
  DateTime? _lastSync;

  static const Duration _syncCooldown = Duration(minutes: 15);
  static const Duration _periodicInterval = Duration(hours: 1);

  /// ProviderRef — main.dart 또는 Bootstrap에서 주입
  Ref? _ref;

  void init(Ref ref) {
    if (_initialized) return;

    _ref = ref;
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicCheck();
    _initialized = true;

    debugPrint('🔄 AppLifecycleSync initialized');
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer?.cancel();
    _ref = null;
    _initialized = false;
  }

  // =============================================================
  // Lifecycle
  // =============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  void _onAppResumed() {
    if (_isInCooldown()) {
      debugPrint('🔄 Sync skipped — cooldown ($_syncCooldown)');
      return;
    }

    _triggerSync(reason: 'app_resumed');
  }

  // =============================================================
  // Periodic (hourly — checks if near 6am)
  // =============================================================

  void _startPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_periodicInterval, (_) {
      final now = DateTime.now();
      // 오전 6시 전후 30분 이내에 sync
      if (now.hour == 6 && now.minute < 30) {
        if (!_isInCooldown()) {
          _triggerSync(reason: 'scheduled_6am');
        }
      }
    });

    debugPrint('🔄 Periodic sync check started (every hour)');
  }

  // =============================================================
  // Sync Logic
  // =============================================================

  Future<void> _triggerSync({required String reason}) async {
    if (_syncing) return;
    if (_ref == null) return;

    _syncing = true;

    try {
      debugPrint('🔄 Health Sync Triggered: $reason');

      final syncNotifier = _ref!.read(healthSyncProvider.notifier);
      final success = await syncNotifier.sync();

      if (success) {
        _lastSync = DateTime.now();
        debugPrint('🔄 Health Sync Completed: $reason');

        // Post-sync: Activity Dispatch (pending events → Feed + Notification)
        try {
          final dispatcher = ActivityDispatcher(supabase.client);
          final dispatched = await dispatcher.dispatchPending();
          if (dispatched > 0) {
            debugPrint('🔄 Activity Dispatched: $dispatched events');
          }
        } catch (e) {
          debugPrint('🔄 Activity Dispatch Error: $e');
        }
      } else {
        debugPrint('🔄 Health Sync Failed: $reason');
      }
    } catch (e) {
      debugPrint('🔄 Health Sync Error: $e');
    } finally {
      _syncing = false;
    }
  }

  bool _isInCooldown() {
    if (_lastSync == null) return false;
    return DateTime.now().difference(_lastSync!) < _syncCooldown;
  }

  /// 외부에서 수동 동기화 요청
  Future<void> syncNow() async {
    _lastSync = null; // bypass cooldown
    await _triggerSync(reason: 'manual');
  }
}
