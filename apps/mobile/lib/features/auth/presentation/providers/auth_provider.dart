import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState, Supabase;

import '../../../../core/bootstrap/bootstrap.dart';
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
    Future.microtask(_initialize);
    _startAuthStateListener();
  }

  final AuthRepository _repository;
  StreamSubscription<AuthState>? _authSubscription;

  // ================================================================
  // Supabase onAuthStateChange 구독
  //
  // 이메일 인증 callback, Google OAuth redirect 등
  // 외부에서 session이 생성/변경될 때 앱이 반응할 수 있도록 한다.
  // ================================================================
  void _startAuthStateListener() {
    // Bootstrap.supabaseInitialized가 true인 경우에만 구독
    if (!Bootstrap.supabaseInitialized) {
      debugPrint('[DIAG][AUTH][STATE] listener SKIP — supabase not initialized');
      return;
    }

    debugPrint('[DIAG][AUTH][STATE] listener START');

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (event) {
        debugPrint('[DIAG][AUTH][STATE] event=${event.event.name}');

        switch (event.event) {
          case AuthChangeEvent.signedIn:
          case AuthChangeEvent.initialSession:
            debugPrint('[DIAG][AUTH][STATE] session=${event.session != null}');
            if (event.session != null) {
              // 세션이 생성됨 → 사용자 정보 갱신
              _refreshAuthState();
            }
            break;

          case AuthChangeEvent.signedOut:
            debugPrint('[DIAG][AUTH][STATE] SIGNED_OUT');
            state = const AsyncData(null);
            break;

          default:
            // TOKEN_REFRESHED, USER_UPDATED, PASSWORD_RECOVERY 등
            break;
        }
      },
      onError: (error) {
        debugPrint('[DIAG][AUTH][STATE] listener ERROR=${error.runtimeType}');
      },
    );
  }

  Future<void> _refreshAuthState() async {
    try {
      final user = await _repository.getCurrentUser();
      debugPrint('[DIAG][AUTH][STATE] refresh user=${user != null}');
      state = AsyncData(user);
    } catch (e, stack) {
      debugPrint('[DIAG][AUTH][STATE] refresh ERROR=${e.runtimeType}');
      state = AsyncError(e, stack);
    }
  }

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
    } on EmailConfirmationRequiredException catch (e) {
      // 이메일 확인 필요 — error로 전달하여 UI에서 처리
      state = AsyncError(e, StackTrace.current);
      // SnackBar 등으로 친절한 메시지 표시를 위해 rethrow 불필요
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
  try {
    await _repository.signOut();

    state = const AsyncData(null);
  } catch (e, stack) {
    state = AsyncError(e, stack);
  }
}

  /// 새로고침
  Future<void> refreshUser() async {
  try {
    final user = await _repository.getCurrentUser();

    state = AsyncData(user);
  } catch (e, stack) {
    state = AsyncError(e, stack);
  }
}

  @override
  void dispose() {
    _authSubscription?.cancel();
    debugPrint('[DIAG][AUTH][STATE] listener disposed');
    super.dispose();
  }
}
