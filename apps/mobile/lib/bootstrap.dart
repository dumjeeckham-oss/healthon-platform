import 'dart:async';

import 'infra/supabase/supabase_client.dart';
import 'core/session/user_session.dart';

class Bootstrap {
  static Future<void> init() async {
    final client = SupabaseClientManager.client;

    // 1. 앱 시작 시 현재 로그인 상태 확인
    final user = client.auth.currentUser;

    if (user != null) {
      UserSession.setUser(user.id);
    }

    // 2. 로그인 상태 변화 실시간 감지
    client.auth.onAuthStateChange.listen((data) {
      final session = data.session;

      if (session?.user != null) {
        UserSession.setUser(session!.user.id);
      } else {
        UserSession.clear();
      }
    });
  }
}
