import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ===============================================================
/// HealthON Mention User Provider
///
/// @ 입력 시 사용자 검색
/// ===============================================================

class MentionUserState {
  final List<MentionUser> users;
  final bool isLoading;
  final String? error;

  const MentionUserState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });
}

class MentionUser {
  final String id;
  final String name;
  final String? avatarUrl;

  const MentionUser({required this.id, required this.name, this.avatarUrl});
}

class MentionUserNotifier extends StateNotifier<MentionUserState> {
  MentionUserNotifier() : super(const MentionUserState());

  /// Mock 사용자 검색
  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const MentionUserState();
      return;
    }

    state = MentionUserState(isLoading: true, users: state.users);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock data — 실제 Supabase users 테이블 검색으로 교체
    const List<MentionUser> mockUsers = [
      MentionUser(id: 'user-001', name: '홍길동'),
      MentionUser(id: 'user-002', name: '김철수'),
      MentionUser(id: 'user-003', name: '이영희'),
      MentionUser(id: 'user-004', name: '박민수'),
      MentionUser(id: 'user-005', name: '최지우'),
      MentionUser(id: 'user-006', name: '정수빈'),
    ];

    final q = query.toLowerCase();
    final results = mockUsers
        .where((u) => u.name.toLowerCase().contains(q) || u.id.toLowerCase().contains(q))
        .toList();

    state = MentionUserState(users: results);
  }

  void clear() => state = const MentionUserState();
}

final mentionUserProvider =
    StateNotifierProvider<MentionUserNotifier, MentionUserState>(
  (ref) => MentionUserNotifier(),
);
