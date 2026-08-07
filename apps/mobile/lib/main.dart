import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/bootstrap/bootstrap.dart';
import 'features/health/data/services/app_lifecycle_sync.dart';

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
    // Don't rethrow — show error UI instead of white screen
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

/// LifecycleSync에 ProviderRef를 주입하기 위한 래퍼
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
    // AppLifecycleSync에 ProviderRef 주입
    AppLifecycleSync().init(ref as Ref<Object?>);
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
