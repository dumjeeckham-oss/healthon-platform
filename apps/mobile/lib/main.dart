import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/bootstrap/bootstrap.dart';
import 'core/services/connectivity_service.dart';
import 'features/health/data/services/app_lifecycle_sync.dart';
import 'features/health/data/services/offline_aware_sync.dart';
import 'features/health/presentation/providers/health_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Bootstrap.initialize();

    runApp(
      const ProviderScope(
        child: _HealthOnRoot(),
      ),
    );
  } catch (e, stackTrace) {
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
  @override
  void initState() {
    super.initState();

    // Rule 8: Connectivity + OfflineAwareSync 초기화
    ConnectivityService.initialize();
    OfflineAwareSyncService().init();

    // Rule 12: LifecycleSync는 순수 Service, Provider 접근은 Widget에서
    AppLifecycleSync().init(
      syncFn: () => ref.read(healthSyncProvider.notifier).sync(),
    );
  }

  @override
  void dispose() {
    AppLifecycleSync().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const HealthOnApp();
  }
}
