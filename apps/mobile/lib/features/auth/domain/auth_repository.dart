import 'auth_user.dart';

/// ===============================================================
///
/// Auth Repository
///
/// 인증 관련 기능을 정의하는 인터페이스
///
/// 실제 구현은
///
/// - SupabaseAuthRepository
/// - FakeAuthRepository (테스트)
///
/// 에서 담당한다.
///
/// ===============================================================

abstract class AuthRepository {
  /// 현재 로그인한 사용자
  Future<AuthUser?> getCurrentUser();

  /// 로그인 여부
  Future<bool> isLoggedIn();

  /// Google 로그인
  Future<AuthUser> signInWithGoogle();

  /// Apple 로그인
  Future<AuthUser> signInWithApple();

  /// Kakao 로그인
  Future<AuthUser> signInWithKakao();

  /// 이메일 로그인
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// 회원가입
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// 로그아웃
  Future<void> signOut();

  /// 회원정보 저장
  Future<void> saveUser(AuthUser user);

  /// 회원정보 수정
  Future<void> updateUser(AuthUser user);

  /// 회원정보 조회
  Future<AuthUser?> fetchUser(String userId);

  /// 회원 탈퇴
  Future<void> deleteAccount();
}