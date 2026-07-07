import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _show(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _signup() async {
    if (_name.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty) {
      _show("모든 항목을 입력해주세요.");
      return;
    }

    if (_password.text.length < 6) {
      _show("비밀번호는 6자 이상 입력해주세요.");
      return;
    }

    await ref.read(authProvider.notifier).signUp(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            Navigator.pop(context);
          }
        },
        error: (e, s) {
          _show(e.toString());
        },
      );
    });

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
                children: [

                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: "이름",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "이메일",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _password,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: "비밀번호",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                        icon: Icon(
                          obscure
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: auth.isLoading ? null : _signup,
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("회원가입"),
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
