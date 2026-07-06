import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        // TODO
        // 로그인 여부 확인

        // router.go('/login');

      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Center(

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.directions_walk,
                size: 90,
              ),

              const SizedBox(height: 24),

              Text(

                "건강ON",

                style: Theme.of(context).textTheme.headlineMedium,

              ),

              const SizedBox(height: 12),

              Text(

                "함께 걸으면 건강이 시작됩니다.",

                style: Theme.of(context).textTheme.bodyLarge,

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
