import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/challenge/screens/challenge_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const challenge = '/challenge';
  static const community = '/community';
  static const profile = '/profile';
  static const admin = '/admin';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,

  routes: [

    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.challenge,
      builder: (context, state) => const ChallengeScreen(),
    ),

    GoRoute(
      path: AppRoutes.community,
      builder: (context, state) => const CommunityScreen(),
    ),

    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),

    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminDashboardScreen(),
    ),

  ],

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("오류"),
      ),
      body: Center(
        child: Text(
          "페이지를 찾을 수 없습니다.\n${state.uri}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  },
);
