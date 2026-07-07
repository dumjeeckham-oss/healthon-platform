import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),

                  const Icon(
                    Icons.favorite,
                    color: Colors.green,
                    size: 80,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "건강ON",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "걸음으로 함께 만드는 건강한 우리 가족",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 50),

                  if (auth.isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: () {
                          ref
                              .read(authProvider.notifier)
                              .signInWithGoogle();
                        },
                        icon: const Icon(Icons.login),
                        label: const Text(
                          "Google로 로그인",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(authProvider.notifier)
                              .signInWithKakao();
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text(
                          "카카오 로그인",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(authProvider.notifier)
                              .signInWithApple();
                        },
                        icon: const Icon(Icons.apple),
                        label: const Text(
                          "Apple 로그인",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  const Divider(),

                  const SizedBox(height: 12),

                  Text(
                    "로그인하면 개인정보 처리방침 및 이용약관에 동의한 것으로 간주됩니다.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Version 1.0.0",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
