import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/provider/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(_initialize);
  }

  Future<void> _initialize() async {
    try {
      await ref.read(authProvider.notifier).refreshUser();

      final authState = ref.read(authProvider);

      authState.when(
        data: (user) {
          if (!mounted) return;

          if (user == null) {
            context.go('/');
          } else {
            context.go('/home');
          }
        },
        loading: () {},
        error: (_, __) {
          if (!mounted) return;
          context.go('/');
        },
      );
    } catch (_) {
      if (!mounted) return;
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.favorite,
              color: Colors.green,
              size: 80,
            ),

            SizedBox(height: 20),

            Text(
              "건강ON",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12),

            Text(
              "매일 걷고 함께 건강해지는 챌린지",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 40),

            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
