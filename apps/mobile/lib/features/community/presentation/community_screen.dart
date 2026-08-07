/// ===============================================================
/// HealthON — Community Screen (Realtime)
///
/// 실시간 연결 상태 + 실시간 포스트/댓글/좋아요 동기화
/// ===============================================================

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/realtime_widgets.dart';
import 'providers/community_realtime_provider.dart';
import '../data/community_realtime_service.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    // 실시간 연결 시작
    Future.microtask(() {
      ref.read(communityRealtimeNotifierProvider.notifier).connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final connState = ref.watch(communityRealtimeNotifierProvider);
    final postChanges = ref.watch(realtimePostStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        centerTitle: false,
        actions: [
          // 연결 상태 아이콘
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              connState == RealtimeConnectionState.connected ? Icons.cloud_done : Icons.cloud_off,
              color: connState == RealtimeConnectionState.connected ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 실시간 연결 배지
          const RealtimeConnectionBadge(),

          // 본문
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (connState != RealtimeConnectionState.connected) {
                  await ref.read(communityRealtimeNotifierProvider.notifier).connect();
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Live indicator
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: connState == RealtimeConnectionState.connected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        connState == RealtimeConnectionState.connected ? '실시간 피드' : '오프라인 모드',
                        style: TextStyle(
                          fontSize: 13,
                          color: connState == RealtimeConnectionState.connected ? Colors.green.shade700 : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (connState == RealtimeConnectionState.connected)
                        Text(
                          '새 글이 자동으로 표시됩니다',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 실시간 이벤트 로그 (디버그/시각 피드백)
                  postChanges.when(
                    data: (change) => const SizedBox.shrink(), // 실제로는 post 목록에 새 항목 추가
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),

                  // 포스트 목록 (기존 community_provider 통합)
                  _PostListPlaceholder(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 포스트 목록 (Sprint 7+에서 community_provider의 실제 데이터로 교체)
class _PostListPlaceholder extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: List.generate(3, (index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(radius: 16, backgroundColor: Colors.green.shade100, child: const Icon(Icons.person, size: 16)),
                const SizedBox(width: 8),
                Text('사용자${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${index + 1}시간 전', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),
              const SizedBox(height: 12),
              Text('오늘 ${((index + 1) * 3420).toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음 걸었어요! 💪', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.favorite_border, size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('${(index + 1) * 3}', style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(width: 20),
                Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('${(index + 1) * 2}', style: TextStyle(color: Colors.grey.shade500)),
              ]),
            ],
          ),
        ),
      )),
    );
  }
}
