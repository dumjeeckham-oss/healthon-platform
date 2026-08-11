import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/bootstrap/bootstrap.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (!Bootstrap.supabaseInitialized) {
      debugPrint('[DIAG][SPLASH] SUPABASE NOT INITIALIZED');
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      context.go('/');
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      if (user == null) {
        context.go('/');
      } else {
        context.go('/home');
      }
    } catch (e) {
      // Supabase not initialized (e.g. web without config) → login
      debugPrint('SplashScreen: Supabase not available — $e');
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_splash.png',
              width: 220,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
