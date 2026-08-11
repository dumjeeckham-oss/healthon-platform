import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/bootstrap/bootstrap.dart';
import 'core/services/connectivity_service.dart';
import 'features/health/data/services/app_lifecycle_sync.dart';
import 'features/health/data/services/offline_aware_sync.dart';
import 'features/health/presentation/providers/health_provider.dart';

/// 안전하게 Supabase 상태 확인 (BEFORE/AFTER 구분용)
void _diagSupabase(String stage) {
  debugPrint('[DIAG][SUPABASE] $stage');

  if (!Bootstrap.supabaseInitialized) {
    // Bootstrap이 완료되지 않았으면 try/catch로 직접 접근 시도
    try {
      final client = Supabase.instance.client;
      debugPrint('[DIAG][SUPABASE] $stage accessible=true');
      debugPrint(
        '[DIAG][SUPABASE] $stage authUserPresent='
        '${client.auth.currentUser != null}',
      );
    } catch (e) {
      debugPrint(
        '[DIAG][SUPABASE] $stage accessible=false '
        'reason=${e.runtimeType}',
      );
    }
    return;
  }

  try {
    final client = Supabase.instance.client;
    debugPrint('[DIAG][SUPABASE] $stage accessible=true');
    debugPrint(
      '[DIAG][SUPABASE] $stage authUserPresent='
      '${client.auth.currentUser != null}',
    );
  } catch (e) {
    debugPrint(
      '[DIAG][SUPABASE] $stage accessible=false '
      'reason=${e.runtimeType}',
    );
  }
}

void main() async {
  debugPrint('[DIAG][MAIN] START');
  debugPrint('[DIAG][MAIN] kIsWeb=$kIsWeb');
  debugPrint('[DIAG][MAIN] platform=${kIsWeb ? "web" : "native"}');
  assert(() { debugPrint('[DIAG][MAIN] debug=true'); return true; }());

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[DIAG][MAIN] WidgetsFlutterBinding=READY');

  debugPrint('[DIAG][SUPABASE] BEFORE_BOOTSTRAP');
    _diagSupabase('BEFORE_BOOTSTRAP');

  try {
    debugPrint('[DIAG][BOOTSTRAP] initialize START');

    await Bootstrap.initialize();

    debugPrint('[DIAG][BOOTSTRAP] initialize END');
    debugPrint(
      '[DIAG][MAIN] Bootstrap '
      'initialized=${Bootstrap.initialized} '
      'supabaseInitialized=${Bootstrap.supabaseInitialized}',
    );

    debugPrint('[DIAG][SUPABASE] AFTER_BOOTSTRAP');
    _diagSupabase('AFTER_BOOTSTRAP');

    debugPrint('[DIAG][MAIN] runApp START');
    runApp(
      const ProviderScope(
        child: _HealthOnRoot(),
      ),
    );
    debugPrint('[DIAG][MAIN] runApp CALLED');
  } catch (e, stackTrace) {
    debugPrint('[DIAG][ERROR] startup error');
    debugPrint('[DIAG][ERROR] type=${e.runtimeType}');
    debugPrint('[DIAG][ERROR] message=$e');
    debugPrint('[DIAG][ERROR] stackTrace first 3 lines:');
    final lines = stackTrace.toString().split('\n');
    for (int i = 0; i < lines.length && i < 3; i++) {
      debugPrint('  ${lines[i]}');
    }

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

class _HealthOnRoot extends ConsumerStatefulWidget {
  const _HealthOnRoot();

  @override
  ConsumerState<_HealthOnRoot> createState() => _HealthOnRootState();
}

class _HealthOnRootState extends ConsumerState<_HealthOnRoot>
    with WidgetsBindingObserver {
  bool _buildLogged = false;
  bool _frameLogged = false;

  @override
  void initState() {
    super.initState();

    debugPrint('[DIAG][ROOT] initState START');

    debugPrint('[DIAG][ROOT] ConnectivityService START');
    ConnectivityService.initialize();
    debugPrint('[DIAG][ROOT] ConnectivityService END');

    debugPrint('[DIAG][ROOT] OfflineAwareSync START');
    OfflineAwareSyncService().init();
    debugPrint('[DIAG][ROOT] OfflineAwareSync END');

    debugPrint('[DIAG][ROOT] LifecycleSync START');
    AppLifecycleSync().init(
      syncFn: () => ref.read(healthSyncProvider.notifier).sync(),
    );
    debugPrint('[DIAG][ROOT] LifecycleSync END');

    debugPrint('[DIAG][ROOT] initState END');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_frameLogged) {
        _frameLogged = true;
        debugPrint('[DIAG][FRAME] first frame rendered');

        debugPrint('[DIAG][SUPABASE] AFTER_APP_RENDER');
        _diagSupabase('AFTER_APP_RENDER');
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[DIAG][LIFECYCLE] state=${state.toString().split('.').last}');
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    debugPrint('[DIAG][LIFECYCLE] dispose');
    AppLifecycleSync().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_buildLogged) {
      _buildLogged = true;
      debugPrint('[DIAG][ROOT] build FIRST');
    }
    return const HealthOnApp();
  }
}
