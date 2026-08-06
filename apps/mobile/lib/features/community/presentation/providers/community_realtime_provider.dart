/// ===============================================================
/// HealthON — Community Realtime Provider
///
/// Supabase Realtime 구독 + 기존 Community Provider 연동
/// 실시간 포스트/댓글/좋아요/북마크 + 연결상태
/// ===============================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'community_realtime_service.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';

// ===============================================================
// Community Realtime Service Provider
// ===============================================================

final communityRealtimeServiceProvider = Provider<CommunityRealtimeService>((ref) {
  final client = Supabase.instance.client;
  return CommunityRealtimeService(client);
});

// ===============================================================
// 연결 상태
// ===============================================================

final communityRealtimeConnectionProvider = StateProvider<RealtimeConnectionState>((ref) {
  final service = ref.watch(communityRealtimeServiceProvider);
  ref.listen(communityRealtimeServiceProvider, (_, svc) {});
  return RealtimeConnectionState.disconnected;
});

// ===============================================================
// Realtime Post Stream
// ===============================================================

final realtimePostStreamProvider = StreamProvider<RealtimePostChange>((ref) {
  return ref.watch(communityRealtimeServiceProvider).postChanges;
});

// ===============================================================
// Realtime Comment Stream
// ===============================================================

final realtimeCommentStreamProvider = StreamProvider<RealtimeCommentChange>((ref) {
  return ref.watch(communityRealtimeServiceProvider).commentChanges;
});

// ===============================================================
// Realtime Like Stream
// ===============================================================

final realtimeLikeStreamProvider = StreamProvider<RealtimeLikeChange>((ref) {
  return ref.watch(communityRealtimeServiceProvider).likeChanges;
});

// ===============================================================
// Typing Indicator Provider
// ===============================================================

final typingUsersProvider = StateProvider<Map<String, String>>((ref) => {});

class RealtimeTypingController {
  final SupabaseClient _client;
  String? _currentPostId;
  String? _currentUserName;
  Timer? _typingTimer;

  RealtimeTypingController(this._client);

  void startTyping(String postId, String userName) {
    _currentPostId = postId;
    _currentUserName = userName;
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), stopTyping);
  }

  void stopTyping() {
    _typingTimer?.cancel();
    _currentPostId = null;
    _currentUserName = null;
  }

  void dispose() {
    _typingTimer?.cancel();
  }
}

final typingControllerProvider = Provider<RealtimeTypingController>((ref) {
  return RealtimeTypingController(ref.watch(communitySupabaseProvider));
});

final communitySupabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

// ===============================================================
// CommunityRealtimeNotifier — 연결 + 구독 관리
// ===============================================================

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

    // 실시간 이벤트 → 기존 provider invalidate
    _postSub = _service.postChanges.listen((change) {
      // 피드 리스트 갱신 (invalidate 또는 refetch)
      _ref.invalidate(allPostsProvider);
      if (change.post != null) {
        _ref.invalidate(postDetailProvider(change.post!.id));
      }
    });

    _commentSub = _service.commentChanges.listen((change) {
      if (change.postId != null) {
        _ref.invalidate(commentsProvider(change.postId!));
      }
    });

    _likeSub = _service.likeChanges.listen((change) {
      // 좋아요 카운트 갱신
      _ref.invalidate(postDetailProvider(change.postId));
    });

    _bookmarkSub = _service.bookmarkChanges.listen((change) {
      _ref.invalidate(postDetailProvider(change.postId));
    });

    // 연결 상태 모니터링
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

final communityRealtimeNotifierProvider = StateNotifierProvider<CommunityRealtimeNotifier, RealtimeConnectionState>((ref) {
  final service = ref.watch(communityRealtimeServiceProvider);
  return CommunityRealtimeNotifier(service, ref);
});

// ===============================================================
// 기존 Provider 참조 (allPostsProvider, postDetailProvider, commentsProvider)
// community_provider.dart에 정의된 것들 — invalidate 대상
// ===============================================================

final allPostsProvider = Provider.autoDispose.family<List<CommunityPost>, CommunityCategory?>((ref, cat) {
  throw UnimplementedError('community_provider.dart 참조');
});

final postDetailProvider = Provider.autoDispose.family<CommunityPost?, String>((ref, id) {
  throw UnimplementedError('community_provider.dart 참조');
});

final commentsProvider = Provider.autoDispose.family<List<CommunityComment>, String>((ref, postId) {
  throw UnimplementedError('community_provider.dart 참조');
});
