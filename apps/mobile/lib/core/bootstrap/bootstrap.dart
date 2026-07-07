import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/connectivity_service.dart';

import 'package:healthon/core/services/connectivity_service.dart';

/// ===============================================================
///
/// HealthON Bootstrap
///
/// 앱 실행 시 필요한 모든 초기화를 담당한다.
///
/// 초기화 순서
///
/// 1. .env 로드
/// 2. 인터넷 연결 확인
/// 3. Supabase 초기화
/// 4. Firebase 초기화 (Sprint 2)
/// 5. Health Connect / Apple Health (Sprint 3)
/// 6. Notification (Sprint 4)
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
      debugPrint('======================================');
      debugPrint('🚀 HealthON Bootstrap Started');
      debugPrint('======================================');

      /// 1. .env
      await _initializeEnvironment();

      /// 2. 인터넷 연결 확인
      await ConnectivityService.initialize();

      /// 3. Supabase
      await _initializeSupabase();

      /// 4. Firebase
      await _initializeFirebase();

      /// 5. Health
      await _initializeHealth();

      /// 6. Notifications
      await _initializeNotifications();

      stopwatch.stop();

      debugPrint('======================================');
      debugPrint(
        '✅ Bootstrap Completed (${stopwatch.elapsedMilliseconds} ms)',
      );
      debugPrint('======================================');

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

  //==============================================================
  // Environment
  //==============================================================

  static Future<void> _initializeEnvironment() async {
    debugPrint('📄 Loading .env');

    await dotenv.load(fileName: '.env');

    debugPrint('✅ .env Loaded');
  }

  //==============================================================
  // Supabase
  //==============================================================

  static Future<void> _initializeSupabase() async {
    debugPrint('☁ Initializing Supabase');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
    );

    debugPrint('✅ Supabase Initialized');
  }

  //==============================================================
  // Firebase
  //==============================================================

  static Future<void> _initializeFirebase() async {
    debugPrint('🔥 Firebase (Skip)');

    // Sprint 2에서 추가
    //
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  }

  //==============================================================
  // Health Connect / Apple Health
  //==============================================================

  static Future<void> _initializeHealth() async {
    debugPrint('❤️ Health Services (Skip)');

    // Sprint 3에서 구현
  }

  //==============================================================
  // Notifications
  //==============================================================

  static Future<void> _initializeNotifications() async {
    debugPrint('🔔 Notifications (Skip)');

    // Sprint 4에서 구현
  }
}
