/// ===============================================================
/// HealthON — Community Realtime Provider
/// Supabase Realtime 구독 + 기존 Community Provider 연동
/// ===============================================================

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/community_realtime_service.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';

// ===============================================================
// Providers
// ===============================================================

final communitySupabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final communityRealtimeServiceProvider = Provider<CommunityRealtimeService>((ref) {
  final client = ref.watch(communitySupabaseProvider);
  return CommunityRealtimeService(client);
});

// ===============================================================
// 연결 상태
// ===============================================================

final communityRealtimeConnectionProvider = StateProvider<RealtimeConnectionState>((ref) {
  return RealtimeConnectionState.disconnected;
});

// ===============================================================
// Realtime Streams
// ===============================================================

final realtimePostStreamProvider = StreamProvider<RealtimePostChange>((ref) {
  return ref.watch(communityRealtimeServiceProvider).postChanges;
});

final realtimeCommentStreamProvider = StreamProvider<RealtimeCommentChange>((ref) {
  return ref.watch(communityRealtimeServiceProvider).commentChanges;
});

final realtimeLikeStreamProvider = StreamProvider<RealtimeLikeChange>((ref) {
  return ref.watch(communityRealtimeServiceProvider).likeChanges;
});

// ===============================================================
// Typing Indicator
// ===============================================================

final typingUsersProvider = StateProvider<Map<String, String>>((ref) => {});

final typingControllerProvider = Provider<RealtimeTypingController>((ref) {
  return RealtimeTypingController(ref.watch(communitySupabaseProvider));
});

class RealtimeTypingController {
  final SupabaseClient _client;
  Timer? _typingTimer;

  RealtimeTypingController(this._client);

  void startTyping(String postId, String userName) {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), stopTyping);
  }

  void stopTyping() {
    _typingTimer?.cancel();
  }

  void dispose() {
    _typingTimer?.cancel();
  }
}

// ===============================================================
// CommunityRealtimeNotifier
// ===============================================================

final communityRealtimeNotifierProvider = StateNotifierProvider<CommunityRealtimeNotifier, RealtimeConnectionState>((ref) {
  final service = ref.watch(communityRealtimeServiceProvider);
  return CommunityRealtimeNotifier(service, ref);
});

class CommunityRealtimeNotifier extends StateNotifier<RealtimeConnectionState> {
  final CommunityRealtimeService _service;
  final Ref _ref;
  StreamSubscription<RealtimePostChange>? _postSub;
  StreamSubscription<RealtimeCommentChange>? _commentSub;
  StreamSubscription<RealtimeLikeChange>? _likeSub;
  StreamSubscription<RealtimeBookmarkChange>? _bookmarkSub;

  CommunityRealtimeNotifier(this._service, this._ref) : super(RealtimeConnectionState.disconnected);

  Future<void> connect() async {
    if (state == RealtimeConnectionState.connected) return;
    await _service.connect();
    state = RealtimeConnectionState.connected;

    _postSub = _service.postChanges.listen((_) {});
    _commentSub = _service.commentChanges.listen((_) {});
    _likeSub = _service.likeChanges.listen((_) {});
    _bookmarkSub = _service.bookmarkChanges.listen((_) {});

    _service.connectionState.addListener(() {
      state = _service.connectionState.value;
    });
  }

  void subscribeToPost(String postId) {
    _service.subscribeToPostComments(postId);
  }

  void unsubscribeFromPost(String postId) {
    _service.unsubscribePostComments(postId);
  }

  @override
  void dispose() {
    _postSub?.cancel();
    _commentSub?.cancel();
    _likeSub?.cancel();
    _bookmarkSub?.cancel();
    _service.dispose();
    super.dispose();
  }
}
