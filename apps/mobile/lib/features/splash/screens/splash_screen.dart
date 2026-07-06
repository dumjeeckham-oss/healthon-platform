import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
      _moveNext,
    );
  }

  void _moveNext() {

    // TODO
    // Supabase 로그인 상태 확인
    // 로그인 되어 있으면 Home
    // 아니면 Login 이동

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF7FAF7),

      body: SafeArea(

        child: Center(

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.favorite,
                size: 90,
                color: Color(0xff2E7D32),
              ),

              const SizedBox(height: 24),

              const Text(
                "건강ON",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2E7D32),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "함께 걷고,\n함께 건강해지는 우리",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 60),

              const CircularProgressIndicator(),

            ],
          ),
        ),
      ),
    );
  }
}
