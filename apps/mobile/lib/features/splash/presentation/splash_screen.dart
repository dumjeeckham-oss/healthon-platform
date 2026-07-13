import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../health/data/services/step_sync_service.dart';

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
    try {
      final supabase = Supabase.instance.client;

      final user = supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;
        context.go('/');
        return;
      }

      //--------------------------------------------------
      // Health Connect 동기화
      //--------------------------------------------------

      try {
        await StepSyncService.instance.syncTodaySteps();
      } catch (e) {
        debugPrint("Health Sync 실패 : $e");
      }

      //--------------------------------------------------
      // Home 이동
      //--------------------------------------------------

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.favorite,
              size: 80,
              color: Colors.green,
            ),

            SizedBox(height: 24),

            Text(
              "건강ON",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
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
