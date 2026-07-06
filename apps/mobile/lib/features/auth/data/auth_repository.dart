import '../../../infra/supabase/supabase_client.dart';

class AuthRepository {
  final _client = SupabaseClientManager.client;

  /// 현재 로그인 사용자
  String? get currentUserId {
    return _client.auth.currentUser?.id;
  }

  /// 로그인 상태 확인
  bool get isLoggedIn {
    return _client.auth.currentUser != null;
  }

  /// 로그인 (예: OAuth)
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
    );
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
