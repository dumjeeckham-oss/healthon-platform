import 'dart:developer';

import 'package:flutter/foundation.dart';

/// ===============================================================
///
/// HealthON Bootstrap
///
/// 앱 실행 시 필요한 모든 초기화를 담당한다.
///
/// 초기화 순서
///
/// 1. 환경설정(.env)
/// 2. Supabase
/// 3. Firebase
/// 4. Health Connect / Apple Health
/// 5. Notification
/// 6. 기타 서비스
///
/// ===============================================================

class Bootstrap {
  Bootstrap._();

  static bool _initialized = false;

  static bool get initialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;

    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('🚀 HealthON Bootstrap Started');

      await _initializeEnvironment();

      await ConnectivityService.initialize();

      await _initializeSupabase();

      await _initializeFirebase();

      await _initializeHealth();

      await _initializeNotifications();

      stopwatch.stop();

      debugPrint(
        '✅ Bootstrap Finished (${stopwatch.elapsedMilliseconds} ms)',
      );

      _initialized = true;
    } catch (e, stackTrace) {
      log(
        'Bootstrap Error',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // ------------------------------------------------------------
  // Environment (.env)
  // ------------------------------------------------------------

  static Future<void> _initializeEnvironment() async {
    debugPrint('• Environment');

    // Sprint 2
    //
    // await dotenv.load(fileName: ".env");
  }

  // ------------------------------------------------------------
  // Supabase
  // ------------------------------------------------------------

  static Future<void> _initializeSupabase() async {
    debugPrint('• Supabase');

    // Sprint 2
    //
    // await Supabase.initialize(...)
  }

  // ------------------------------------------------------------
  // Firebase
  // ------------------------------------------------------------

  static Future<void> _initializeFirebase() async {
    debugPrint('• Firebase');

    // Sprint 3
    //
    // await Firebase.initializeApp();
  }

  // ------------------------------------------------------------
  // Health Connect / Apple Health
  // ------------------------------------------------------------

  static Future<void> _initializeHealth() async {
    debugPrint('• Health');
  }

  // ------------------------------------------------------------
  // Notifications
  // ------------------------------------------------------------

  static Future<void> _initializeNotifications() async {
    debugPrint('• Notifications');
  }
}
