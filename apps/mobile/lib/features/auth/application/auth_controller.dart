import '../data/auth_repository.dart';

class AuthController {
  final AuthRepository repository;

  AuthController(this.repository);

  String? get userId => repository.currentUserId;

  bool get isLoggedIn => repository.isLoggedIn;

  Future<void> login() async {
    await repository.signInWithGoogle();
  }

  Future<void> logout() async {
    await repository.signOut();
  }
}
