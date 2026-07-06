import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

import 'core/bootstrap/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Bootstrap.initialize();

    runApp(
      const ProviderScope(
        child: HealthOnApp(),
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
