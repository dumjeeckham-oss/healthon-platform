import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/challenge/presentation/challenge_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/mypage/presentation/my_page_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const challenge = '/challenge';
  static const community = '/community';
  static const profile = '/profile';
  static const admin = '/admin';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,

  routes: [

    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),

    GoRoute(
      path: AppRoutes.home,
      builder: (_, __) => const HomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.challenge,
      builder: (_, __) => const ChallengeScreen(),
    ),

    GoRoute(
      path: AppRoutes.community,
      builder: (_, __) => const CommunityScreen(),
    ),

    GoRoute(
      path: AppRoutes.profile,
      builder: (_, __) => const MyPageScreen(),
    ),

    GoRoute(
      path: AppRoutes.admin,
      builder: (_, __) => const _AdminPlaceholderScreen(),
    ),

  ],

  errorBuilder: (_, state) {
    return Scaffold(
      appBar: AppBar(title: const Text("오류")),
      body: Center(
        child: Text(
          "페이지를 찾을 수 없습니다.\n${state.uri}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  },
);

class _AdminPlaceholderScreen extends StatelessWidget {
  const _AdminPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("관리자 화면 준비중"),
      ),
    );
  }
}
