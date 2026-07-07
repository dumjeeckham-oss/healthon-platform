import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

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
  final SupabaseClient _supabase = Supabase.instance.client;

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
    final GoogleSignIn google = GoogleSignIn.instance;

    await google.initialize();

    final account = await google.authenticate();

    final auth = account.authentication;

    final idToken = auth.idToken;

    if (idToken == null || idToken.isEmpty) {
  throw Exception("Google 인증 토큰을 가져오지 못했습니다.");
}

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    final user = _supabase.auth.currentUser;

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
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('회원가입 실패');
    }

    final authUser = AuthUser(
      id: user.id,
      email: email,
      name: name,
    );

    await saveUser(authUser);

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
