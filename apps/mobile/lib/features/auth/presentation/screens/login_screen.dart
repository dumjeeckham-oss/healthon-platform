import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/supabase_auth_repository.dart' show EmailConfirmationRequiredException;
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _emailLogin() async {
    debugPrint('[DIAG][AUTH][EMAIL] LOGIN BUTTON PRESSED');
    final emailPresent = _emailController.text.trim().isNotEmpty;
    final passwordPresent = _passwordController.text.isNotEmpty;
    debugPrint('[DIAG][AUTH][EMAIL] emailPresent=$emailPresent');
    debugPrint('[DIAG][AUTH][EMAIL] passwordPresent=$passwordPresent');

    if (!emailPresent || !passwordPresent) {
      _showMessage("이메일과 비밀번호를 입력해주세요.");
      return;
    }

    debugPrint('[DIAG][AUTH][EMAIL] SIGN_IN START');
    try {
      await ref.read(authProvider.notifier).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      debugPrint('[DIAG][AUTH][EMAIL] SIGN_IN SUCCESS');
    } catch (e) {
      debugPrint('[DIAG][AUTH][EMAIL] SIGN_IN FAILED');
      debugPrint('[DIAG][AUTH][EMAIL] ERROR TYPE=${e.runtimeType}');
      debugPrint('[DIAG][AUTH][EMAIL] ERROR=$e');
      rethrow;
    }
  }

  Future<void> _googleLogin() async {
    debugPrint('[DIAG][AUTH][GOOGLE] BUTTON PRESSED');
    debugPrint('[DIAG][AUTH][GOOGLE] SIGN_IN START');
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      debugPrint('[DIAG][AUTH][GOOGLE] SIGN_IN SUCCESS');
    } catch (e) {
      debugPrint('[DIAG][AUTH][GOOGLE] SIGN_IN FAILED');
      debugPrint('[DIAG][AUTH][GOOGLE] ERROR TYPE=${e.runtimeType}');
      debugPrint('[DIAG][AUTH][GOOGLE] ERROR=$e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && mounted) {
            context.go('/home');
          }
        },
        error: (error, stack) {
          // EmailConfirmationRequiredException → 사용자에게 안내
          if (error is EmailConfirmationRequiredException) {
            _showMessage(error.message);
          } else {
            _showMessage(error.toString());
          }
        },
      );
    });

    final loading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    Image.asset(
                      'assets/images/logo_main.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "건강ON",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "매일 걷고 함께 건강해지는 챌린지",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 50),

                    TextField(
                      controller: _emailController,
                      enabled: !loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.email,
                      ],
                      decoration: const InputDecoration(
                        labelText: "이메일",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: _passwordController,
                      enabled: !loading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [
                        AutofillHints.password,
                      ],
                      onSubmitted: (_) => _emailLogin(),
                      decoration: InputDecoration(
                        labelText: "비밀번호",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    FilledButton(
                      onPressed: loading ? null : _emailLogin,
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("로그인"),
                    ),

                    const SizedBox(height: 16),

                    OutlinedButton.icon(
                      onPressed: loading ? null : _googleLogin,
                      icon: const Icon(Icons.login),
                      label: const Text("Google로 로그인"),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("처음 오셨나요?"),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () {
                                  context.push('/signup');
                                },
                          child: const Text("회원가입"),
                        ),
                      ],
                    ),

                    TextButton(
                      onPressed: loading
                          ? null
                          : () {
                              _showMessage("비밀번호 찾기는 준비 중입니다.");
                            },
                      child: const Text("비밀번호를 잊으셨나요?"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
