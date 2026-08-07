import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ===============================================================
///
/// HealthON Bootstrap
///
/// Rule 8: dotenv + Supabase 만 수행. Business Logic 금지.
///
/// 초기화 순서
///
/// 1. .env 로드
/// 2. Supabase 초기화
///
/// 그 외 서비스(Connectivity, Health 등)는 Widget에서 초기화.
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

      /// 2. Supabase
      await _initializeSupabase();

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
    // On web, dotenv asset loading does not work — use --dart-define instead
    if (kIsWeb) {
      debugPrint('📄 Web: skip .env, use --dart-define');
      return;
    }

    debugPrint('📄 Loading .env');

    try {
      await dotenv.load(fileName: '.env');
      debugPrint('✅ .env Loaded');
    } catch (_) {
      debugPrint('⚠ .env not found, using system env vars');
    }
  }

  //==============================================================
  // Supabase
  //==============================================================

  static Future<void> _initializeSupabase() async {
    debugPrint('☁ Initializing Supabase');

    // Try .env (native) first, then dart-define (web fallback)
    String url = '';
    String key = '';

    try {
      url = dotenv.env['SUPABASE_URL'] ?? '';
      key = dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
    } catch (_) {
      // dotenv not initialized (web) — use dart-define only
    }

    url = url.isNotEmpty ? url : const String.fromEnvironment('SUPABASE_URL');
    key = key.isNotEmpty ? key : const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

    if (url.isEmpty || key.isEmpty) {
      debugPrint('⚠ Supabase config missing — skipping init');
      return;
    }

    await Supabase.initialize(
      url: url,
      publishableKey: key,
    );

    debugPrint('✅ Supabase Initialized');
  }
}
