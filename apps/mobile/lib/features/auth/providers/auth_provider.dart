import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

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
/// Auth Controller
///
/// 로그인 상태 관리
///
/// ===============================================================

class AuthController extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthController(this._repository)
      : super(const AsyncValue.loading()) {
    initialize();
  }

  final AuthRepository _repository;

  /// 앱 시작 시 로그인 확인
  Future<void> initialize() async {
    try {
      final user = await _repository.getCurrentUser();

      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 로그인 여부
  bool get isLoggedIn {
    return state.value != null;
  }

  /// 현재 사용자
  AuthUser? get currentUser {
    return state.value;
  }

  //==============================================================
  // Google Login
  //==============================================================

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.signInWithGoogle();

      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  //==============================================================
  // Apple Login
  //==============================================================

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.signInWithApple();

      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  //==============================================================
  // Kakao Login
  //==============================================================

  Future<void> signInWithKakao() async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.signInWithKakao();

      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  //==============================================================
  // Email Login
  //==============================================================

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );

      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  //==============================================================
  // Logout
  //==============================================================

  Future<void> signOut() async {
    await _repository.signOut();

    state = const AsyncValue.data(null);
  }

  //==============================================================
  // Refresh
  //==============================================================

  Future<void> refresh() async {
    final user = await _repository.getCurrentUser();

    state = AsyncValue.data(user);
  }
}

/// ===============================================================
///
/// Global Provider
///
/// ===============================================================

final authProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthUser?>>(
  (ref) {
    return AuthController(
      ref.read(authRepositoryProvider),
    );
  },
);
