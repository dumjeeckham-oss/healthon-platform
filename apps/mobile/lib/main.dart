import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/bootstrap/bootstrap.dart';
import 'core/services/connectivity_service.dart';
import 'features/health/data/services/app_lifecycle_sync.dart';
import 'features/health/data/services/offline_aware_sync.dart';
import 'features/health/presentation/providers/health_provider.dart';

void main() async {
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  debugPrint('🚀 HealthON main() START');
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('✅ WidgetsFlutterBinding initialized');

  try {
    debugPrint('🔧 [MAIN] Bootstrap.initialize() START');

    await Bootstrap.initialize();

    debugPrint(
      '🔧 [MAIN] Bootstrap.initialize() COMPLETED '
      '(initialized=${Bootstrap.initialized})',
    );

    debugPrint('📱 [MAIN] runApp() START');
    runApp(
      const ProviderScope(
        child: _HealthOnRoot(),
      ),
    );
    debugPrint('📱 [MAIN] runApp() CALLED');
  } catch (e, stackTrace) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ HealthON STARTUP ERROR');
    debugPrint('❌ [MAIN] Bootstrap.initialize() FAILED');
    debugPrint('❌ [MAIN] Error type: ${e.runtimeType}');
    debugPrint('❌ [MAIN] Error: $e');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // stackTrace는 FlutterError.reportError에 맡김
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: e,
        stack: stackTrace,
      ),
    );
    runApp(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  '앱 초기화 중 오류가 발생했습니다.\n\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 앱 루트 위젯 — 서비스 초기화 + LifecycleSync 콜백 연결
/// Rule 10: Widget만 Provider를 안다.
class _HealthOnRoot extends ConsumerStatefulWidget {
  const _HealthOnRoot();

  @override
  ConsumerState<_HealthOnRoot> createState() => _HealthOnRootState();
}

class _HealthOnRootState extends ConsumerState<_HealthOnRoot>
    with WidgetsBindingObserver {
  bool _buildLogged = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🌱 [_HealthOnRoot] initState START');

    // Rule 8: Connectivity + Health 서비스는 Widget에서 초기화
    debugPrint('🌐 [_HealthOnRoot] ConnectivityService.initialize START');
    ConnectivityService.initialize();
    debugPrint('🌐 [_HealthOnRoot] ConnectivityService.initialize COMPLETED');

    debugPrint('💾 [_HealthOnRoot] OfflineAwareSyncService.init START');
    OfflineAwareSyncService().init();
    debugPrint('💾 [_HealthOnRoot] OfflineAwareSyncService.init COMPLETED');

    // Rule 12: LifecycleSync는 순수 Service, Provider 접근은 Widget에서
    debugPrint('🔄 [_HealthOnRoot] AppLifecycleSync.init START');
    AppLifecycleSync().init(
      syncFn: () => ref.read(healthSyncProvider.notifier).sync(),
    );
    debugPrint('🔄 [_HealthOnRoot] AppLifecycleSync.init COMPLETED');

    debugPrint('🌱 [_HealthOnRoot] initState COMPLETED');
  }

  @override
  void dispose() {
    debugPrint('🧹 [_HealthOnRoot] dispose');
    AppLifecycleSync().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_buildLogged) {
      _buildLogged = true;
      debugPrint('🎨 [_HealthOnRoot] build FIRST');
    }

    debugPrint('🎨 [_HealthOnRoot] returning HealthOnApp');
    return const HealthOnApp();
  }
}
