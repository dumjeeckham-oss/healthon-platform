import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class HealthOnApp extends StatelessWidget {
  const HealthOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '건강ON',
      debugShowCheckedModeBanner: false,

      theme: lightTheme,

      routerConfig: router,
    );
  }
}
