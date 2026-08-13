import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
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

    // public.users에서 프로필 조회 시도
    try {
      final profile = await fetchUser(user.id);
      if (profile != null) return profile;
    } catch (e) {
      debugPrint('[DIAG][AUTH][PROFILE] fetchUser SELECT failed, '
          'will try save (${e.runtimeType})');
    }

    // 프로필이 없음 → authenticated session으로 생성
    final session = _supabase.auth.currentSession;
    if (session != null) {
      final authUser = AuthUser(
        id: user.id,
        email: user.email,
        name: user.userMetadata?['full_name'],
        photoUrl: user.userMetadata?['avatar_url'],
      );
      debugPrint('[DIAG][AUTH][PROFILE] SAVE START (post-auth)');
      try {
        await saveUser(authUser);
        debugPrint('[DIAG][AUTH][PROFILE] SAVE SUCCESS');
      } catch (e) {
        debugPrint('[DIAG][AUTH][PROFILE] SAVE ERROR=${e.runtimeType}: $e');
      }
      return authUser;
    }

    // session도 없음 → auth metadata만으로 반환
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
    debugPrint('[DIAG][AUTH][GOOGLE] SIGN_IN START');
    debugPrint('[DIAG][AUTH][GOOGLE] platform=${kIsWeb ? "web" : "native"}');

    if (kIsWeb) {
      // Web: Supabase OAuth redirect (google_sign_in 패키지 불필요)
      return _signInWithGoogleWeb();
    } else {
      // Native: GoogleSignIn + ID Token 방식
      return _signInWithGoogleNative();
    }
  }

  /// Web: Supabase OAuth redirect
  Future<AuthUser> _signInWithGoogleWeb() async {
    debugPrint('[DIAG][AUTH][GOOGLE] OAUTH START (Web)');
    debugPrint('[DIAG][AUTH][GOOGLE] REDIRECT START');

    // OAuth redirect — onAuthStateChange가 SIGNED_IN을 감지하여
    // AuthNotifier가 자동으로 상태를 갱신한다.
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: Uri.base.origin,
    );

    // signInWithOAuth는 redirect 후 페이지를 나가므로
    // 이 아래 코드는 redirect 이후 콜백에서 실행된다.
    // 세션은 onAuthStateChange → SIGNED_IN 이벤트로 복구됨.

    final user = _supabase.auth.currentUser;
    debugPrint('[DIAG][AUTH][GOOGLE] CALLBACK user=${user != null}');
    debugPrint('[DIAG][AUTH][GOOGLE] CALLBACK session=${_supabase.auth.currentSession != null}');

    if (user == null) {
      throw Exception('Google 로그인에 실패했습니다.');
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

  /// Native: GoogleSignIn + ID Token 방식
  Future<AuthUser> _signInWithGoogleNative() async {
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
      emailRedirectTo: 'http://localhost:9876',
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

    // session이 있을 때만 public.users 저장
    // session == null → 이메일 확인 필요 → 인증 완료 후 저장
    if (session != null) {
      debugPrint('[DIAG][AUTH][SIGNUP] USER_PROFILE SAVE START');
      await saveUser(authUser);
      debugPrint('[DIAG][AUTH][SIGNUP] USER_PROFILE SAVE SUCCESS');
      debugPrint('[DIAG][AUTH][SIGNUP] session established');
      return authUser;
    }

    debugPrint('[DIAG][AUTH][SIGNUP] EMAIL CONFIRMATION REQUIRED');
    throw EmailConfirmationRequiredException(
      '회원가입이 완료되었습니다. 입력하신 이메일에서 인증 링크를 확인해주세요.',
      authUser: authUser,
    );
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
    debugPrint('[DIAG][AUTH][PROFILE] UPSERT START');
    try {
      final json = user.toJson();
      // created_at NOT NULL 컬럼 대응 — null이면 현재 시각으로 채움
      if (json['created_at'] == null) {
        json['created_at'] = DateTime.now().toIso8601String();
        debugPrint('[DIAG][AUTH][PROFILE] created_at defaulted to now');
      }
      await _supabase
      .from('users')
      .upsert(
        json,
        onConflict: 'id',
      );
      debugPrint('[DIAG][AUTH][PROFILE] UPSERT SUCCESS');
    } catch (e) {
      debugPrint('[DIAG][AUTH][PROFILE] UPSERT ERROR');
      debugPrint('[DIAG][AUTH][PROFILE] error=${e.runtimeType}');
      debugPrint('[DIAG][AUTH][PROFILE] message=$e');
      rethrow;
    }
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
