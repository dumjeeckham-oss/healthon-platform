import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF7FAF7),

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(24),

          child: Column(

            children: [

              const Spacer(),

              const Icon(
                Icons.favorite,
                size: 90,
                color: Color(0xff2E7D32),
              ),

              const SizedBox(height: 24),

              const Text(
                "건강ON",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2E7D32),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "생활 속 건강습관을\n함께 만들어가요",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),

              const Spacer(),

              _LoginButton(
                text: "Google로 시작하기",
                icon: Icons.login,
                color: Colors.white,
                textColor: Colors.black,
              ),

              const SizedBox(height: 16),

              _LoginButton(
                text: "카카오로 시작하기",
                icon: Icons.chat_bubble,
                color: Color(0xffFEE500),
                textColor: Colors.black,
              ),

              const SizedBox(height: 16),

              _LoginButton(
                text: "Apple로 시작하기",
                icon: Icons.apple,
                color: Colors.black,
                textColor: Colors.white,
              ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "비회원 둘러보기",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "로그인하면\n걸음 기록과 챌린지 진행 상황이 저장됩니다.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {

  final String text;
  final IconData icon;
  final Color color;
  final Color textColor;

  const _LoginButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,

      height: 56,

      child: ElevatedButton.icon(

        style: ElevatedButton.styleFrom(

          backgroundColor: color,

          foregroundColor: textColor,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          elevation: 1,

        ),

        onPressed: () {},

        icon: Icon(icon),

        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),

      ),
    );
  }
}
