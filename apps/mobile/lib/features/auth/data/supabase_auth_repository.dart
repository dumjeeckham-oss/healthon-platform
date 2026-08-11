import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../core/bootstrap/bootstrap.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// ===============================================================
///
/// Supabase Auth Repository
///
/// 실제 인증 처리
///
/// Google
/// Apple
/// Kakao(추후)
/// Email
///
/// ===============================================================

class SupabaseAuthRepository implements AuthRepository {
  // Lazy with Bootstrap.supabaseInitialized guard
  SupabaseClient get _supabase {
    if (!Bootstrap.supabaseInitialized) {
      throw StateError(
        'Supabase가 초기화되지 않았습니다. '
        '환경설정(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY)을 확인하세요.',
      );
    }
    return Supabase.instance.client;
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return null;

    final profile = await fetchUser(user.id);

if (profile != null) {
  return profile;
}

return AuthUser(
  id: user.id,
  email: user.email,
  name: user.userMetadata?['full_name'],
  photoUrl: user.userMetadata?['avatar_url'],
);
  }

  @override
  Future<bool> isLoggedIn() async {
    return _supabase.auth.currentUser != null;
  }

  // ==========================================================
  // Google Login
  // ==========================================================

  @override
  Future<AuthUser> signInWithGoogle() async {
    debugPrint('[DIAG][AUTH][GOOGLE] signInWithGoogle START');

    final GoogleSignIn google = GoogleSignIn.instance;

    debugPrint('[DIAG][AUTH][GOOGLE] GoogleSignIn.initialize START');
    await google.initialize();
    debugPrint('[DIAG][AUTH][GOOGLE] GoogleSignIn.initialize DONE');

    debugPrint('[DIAG][AUTH][GOOGLE] GoogleSignIn.authenticate START');
    final account = await google.authenticate();
    debugPrint('[DIAG][AUTH][GOOGLE] GOOGLE ACCOUNT RECEIVED');

    final auth = account.authentication;

    final idToken = auth.idToken;
    debugPrint('[DIAG][AUTH][GOOGLE] ID_TOKEN RECEIVED=${idToken != null && idToken.isNotEmpty}');

    if (idToken == null || idToken.isEmpty) {
      throw Exception("Google 인증 토큰을 가져오지 못했습니다.");
    }

    debugPrint('[DIAG][AUTH][GOOGLE] SUPABASE SIGN_IN START');
    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    debugPrint('[DIAG][AUTH][GOOGLE] SUPABASE SIGN_IN DONE');

    final user = _supabase.auth.currentUser;
    debugPrint('[DIAG][AUTH][GOOGLE] currentUser present=${user != null}');

    if (user == null) {
      throw Exception('로그인 실패');
    }

    final authUser = AuthUser(
      id: user.id,
      email: user.email,
      name: user.userMetadata?['full_name'],
      photoUrl: user.userMetadata?['avatar_url'],
    );

    await saveUser(authUser);

    return authUser;
  }

  // ==========================================================
  // Apple
  // ==========================================================

  @override
  Future<AuthUser> signInWithApple() async {
    throw UnimplementedError(
      'Sprint3에서 Apple Login 구현',
    );
  }

  // ==========================================================
  // Kakao
  // ==========================================================

  @override
  Future<AuthUser> signInWithKakao() async {
    throw UnimplementedError(
      'Sprint3에서 Kakao Login 구현',
    );
  }

  // ==========================================================
  // Email Login
  // ==========================================================

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('로그인 실패');
    }

    return (await fetchUser(user.id))!;
  }

  // ==========================================================
  // SignUp
  // ==========================================================

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    debugPrint('[DIAG][AUTH][SIGNUP] SUPABASE_AUTH START');
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    debugPrint('[DIAG][AUTH][SIGNUP] SUPABASE_AUTH SUCCESS');
    debugPrint('[DIAG][AUTH][SIGNUP] user.id=${response.user?.id ?? "null"}');
    debugPrint('[DIAG][AUTH][SIGNUP] session present=${response.session != null}');

    final user = response.user;
    final session = response.session;

    if (user == null) {
      throw Exception('회원가입 실패: Supabase Auth 응답에 user가 없습니다.');
    }

    final authUser = AuthUser(
      id: user.id,
      email: email,
      name: name,
    );

    debugPrint('[DIAG][AUTH][SIGNUP] USER_PROFILE SAVE START');
    await saveUser(authUser);
    debugPrint('[DIAG][AUTH][SIGNUP] USER_PROFILE SAVE SUCCESS');

    // 이메일 확인이 필요한 경우 세션이 없음 → 예외로 구분
    if (session == null) {
      debugPrint('[DIAG][AUTH][SIGNUP] EMAIL CONFIRMATION REQUIRED');
      throw EmailConfirmationRequiredException(
        '회원가입이 완료되었습니다. 입력하신 이메일에서 인증 링크를 확인해주세요.',
        authUser: authUser,
      );
    }

    debugPrint('[DIAG][AUTH][SIGNUP] session established');
    return authUser;
  }

  // ==========================================================
  // Logout
  // ==========================================================

  @override
  Future<void> signOut() async {
    try {
  await GoogleSignIn.instance.signOut();
} catch (_) {}

    await _supabase.auth.signOut();
  }

  // ==========================================================
  // Save User
  // ==========================================================

  @override
  Future<void> saveUser(AuthUser user) async {
    await _supabase
    .from('users')
    .upsert(
      user.toJson(),
      onConflict: 'id',
    );
  }

  // ==========================================================
  // Update User
  // ==========================================================

  @override
  Future<void> updateUser(AuthUser user) async {
    final response = await _supabase
    .from('users')
    .update(user.toJson())
    .eq('id', user.id)
    .select()
    .maybeSingle();

if (response == null) {
  throw Exception("사용자 수정 실패");
}
  }

  // ==========================================================
  // Fetch User
  // ==========================================================

  @override
  Future<AuthUser?> fetchUser(String userId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return AuthUser.fromJson(response);
  }

  // ==========================================================
  // Delete
  // ==========================================================

  @override
  Future<void> deleteAccount() async {
    throw UnimplementedError(
      '회원탈퇴는 관리자 API에서 처리',
    );
  }
}

/// 이메일 확인이 필요한 경우 발생하는 예외
class EmailConfirmationRequiredException implements Exception {
  final String message;
  final AuthUser authUser;

  EmailConfirmationRequiredException(this.message, {required this.authUser});

  @override
  String toString() => message;
}
