import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
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
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: e,
        stack: stackTrace,
      ),
    );
    rethrow;
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
    AppLifecycleSync().init(ref);
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
