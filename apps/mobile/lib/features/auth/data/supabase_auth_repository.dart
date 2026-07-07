import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    return fetchUser(user.id);
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
    final GoogleSignIn google = GoogleSignIn();

    final account = await google.signIn();

    if (account == null) {
      throw Exception('Google 로그인 취소');
    }

    final auth = await account.authentication;

    final idToken = auth.idToken;

    if (idToken == null) {
      throw Exception('Google ID Token 없음');
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
    await _supabase.auth.signOut();
  }

  // ==========================================================
  // Save User
  // ==========================================================

  @override
  Future<void> saveUser(AuthUser user) async {
    await _supabase.from('users').upsert(
          user.toJson(),
        );
  }

  // ==========================================================
  // Update User
  // ==========================================================

  @override
  Future<void> updateUser(AuthUser user) async {
    await _supabase
        .from('users')
        .update(user.toJson())
        .eq('id', user.id);
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
