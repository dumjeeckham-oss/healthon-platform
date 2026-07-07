import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/home_screen.dart';

final router = GoRouter(
  debugLogDiagnostics: true,

  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      name: 'login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),
  ],

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오류'),
      ),
      body: Center(
        child: Text(
          '페이지를 찾을 수 없습니다.\n\n${state.uri}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  },
);
