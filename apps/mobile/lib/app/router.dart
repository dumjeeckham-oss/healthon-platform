import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login/login_screen.dart';
import '../features/home/presentation/home_screen.dart';

/// ===============================================================
///
/// HealthON Router
///
/// 화면 이동을 관리한다.
///
/// /        -> Login
/// /home    -> Home
///
/// ===============================================================

final router = GoRouter(
  debugLogDiagnostics: true,

  initialLocation: '/',

  routes: [
    /// 로그인
    GoRoute(
      path: '/',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// 홈
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오류'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '페이지를 찾을 수 없습니다.\n\n'
            '경로 : ${state.uri}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  },
);
