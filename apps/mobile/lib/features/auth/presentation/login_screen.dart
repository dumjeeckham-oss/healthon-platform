import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository();

    return Scaffold(
      backgroundColor: const Color(0xffF7FAF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "로그인",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () async {
                  await auth.signInWithGoogle();
                },
                icon: const Icon(Icons.login),
                label: const Text("Google로 시작하기"),
              ),

              const SizedBox(height: 20),

              const Text(
                "로그인 후 걸음 데이터가 자동으로 기록됩니다",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
