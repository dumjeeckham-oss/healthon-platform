import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("로그인"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            const Spacer(),

            ElevatedButton.icon(

              onPressed: () {},

              icon: const Icon(Icons.login),

              label: const Text("Google 로그인"),

            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(

              onPressed: () {},

              icon: const Icon(Icons.apple),

              label: const Text("Apple 로그인"),

            ),

            const SizedBox(height: 16),

            OutlinedButton(

              onPressed: () {},

              child: const Text("카카오 로그인 (예정)"),

            ),

            const Spacer(),

            Text(

              "로그인하면 이용약관 및 개인정보처리방침에 동의한 것으로 간주됩니다.",

              textAlign: TextAlign.center,

            ),

          ],

        ),

      ),

    );

  }

}
