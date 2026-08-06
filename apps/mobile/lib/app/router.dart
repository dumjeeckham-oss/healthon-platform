import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/admin/screens/admin_layout.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_members_screen.dart';
import '../features/admin/screens/admin_notices_screen.dart';
import '../features/admin/screens/admin_reports_screen.dart';
import '../features/admin/screens/admin_challenges_screen.dart';
import '../features/admin/screens/admin_missions_screen.dart';
import '../features/admin/screens/admin_seasons_screen.dart';
import '../features/admin/screens/admin_banners_screen.dart';

import 'main_navigation.dart';

final router = GoRouter(
  debugLogDiagnostics: true,

  initialLocation: '/splash',

  routes: [
    GoRoute(
  path: '/splash',
  builder: (context, state) => const SplashScreen(),
),
    GoRoute(
      path: '/',
      name: 'login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) {
        return const SignupScreen();
  },
),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
        return const MainNavigation();
      },
    ),

    // ============================================================
    // Admin CMS
    // ============================================================
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/members',
          name: 'admin-members',
          builder: (context, state) => const AdminMembersScreen(),
        ),
        GoRoute(
          path: '/admin/notices',
          name: 'admin-notices',
          builder: (context, state) => const AdminNoticesScreen(),
        ),
        GoRoute(
          path: '/admin/reports',
          name: 'admin-reports',
          builder: (context, state) => const AdminReportsScreen(),
        ),
        GoRoute(
          path: '/admin/challenges',
          name: 'admin-challenges',
          builder: (context, state) => const AdminChallengesScreen(),
        ),
        GoRoute(
          path: '/admin/missions',
          name: 'admin-missions',
          builder: (context, state) => const AdminMissionsScreen(),
        ),
        GoRoute(
          path: '/admin/seasons',
          name: 'admin-seasons',
          builder: (context, state) => const AdminSeasonsScreen(),
        ),
        GoRoute(
          path: '/admin/banners',
          name: 'admin-banners',
          builder: (context, state) => const AdminBannersScreen(),
        ),
      ],
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
