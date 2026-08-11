import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/supabase_auth_repository.dart' show EmailConfirmationRequiredException;
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _signup() async {
    debugPrint('[DIAG][AUTH][SIGNUP] START');

    if (_nameController.text.trim().isEmpty) {
      _showMessage("이름을 입력해주세요.");
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (email.isEmpty) {
      _showMessage("이메일을 입력해주세요.");
      return;
    }

    if (password.length < 6) {
      _showMessage("비밀번호는 6자 이상 입력해주세요.");
      return;
    }

    debugPrint('[DIAG][AUTH][SIGNUP] emailPresent=true');
    debugPrint('[DIAG][AUTH][SIGNUP] namePresent=true');
    debugPrint('[DIAG][AUTH][SIGNUP] calling signUp provider...');

    try {
      await ref.read(authProvider.notifier).signUp(
            name: name,
            email: email,
            password: password,
          );
      debugPrint('[DIAG][AUTH][SIGNUP] COMPLETE');
    } catch (e) {
      debugPrint('[DIAG][AUTH][SIGNUP] FAILED');
      debugPrint('[DIAG][AUTH][SIGNUP] ERROR TYPE=${e.runtimeType}');
      debugPrint('[DIAG][AUTH][SIGNUP] ERROR=$e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && mounted) {
            context.go('/home');
          }
        },
        error: (e, _) {
          if (e is EmailConfirmationRequiredException) {
            _showMessage(e.message);
          } else {
            _showMessage(e.toString());
          }
        },
      );
    });

    final loading = ref.watch(authProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  Image.asset(
                    'assets/images/logo_main.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "건강ON 회원가입",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "이름",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "이메일",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: "비밀번호",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  FilledButton(
                    onPressed: loading ? null : _signup,
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("회원가입"),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text("이미 계정이 있으신가요? 로그인"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
