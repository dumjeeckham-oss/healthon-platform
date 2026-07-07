import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/supabase_auth_repository.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_user.dart';

/// ===============================================================
///
/// Repository Provider
///
/// ===============================================================

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(),
);

/// ===============================================================
///
/// 현재 로그인 사용자
///
/// null이면 로그인 안됨
///
/// ===============================================================

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>(
  (ref) {
    final repository = ref.read(authRepositoryProvider);

    return AuthNotifier(repository);
  },
);

/// ===============================================================
///
/// Auth Notifier
///
/// ===============================================================

class AuthNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthNotifier(this._repository)
      : super(const AsyncLoading()) {
    _initialize();
  }

  final AuthRepository _repository;

  Future<void> _initialize() async {
    try {
      final user = await _repository.getCurrentUser();

      state = AsyncData(user);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Google Login
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    try {
      final user = await _repository.signInWithGoogle();

      state = AsyncData(user);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Email Login
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );

      state = AsyncData(user);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        name: name,
      );

      state = AsyncData(user);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _repository.signOut();

    state = const AsyncData(null);
  }

  /// 새로고침
  Future<void> refreshUser() async {
    final user = await _repository.getCurrentUser();

    state = AsyncData(user);
  }
}
