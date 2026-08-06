/// ===============================================================
/// HealthON — Realtime Connection Badge
///
/// 커뮤니티 화면 상단 연결 상태 표시
/// ===============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/community_realtime_provider.dart';

class RealtimeConnectionBadge extends ConsumerStatefulWidget {
  const RealtimeConnectionBadge({super.key});

  @override
  ConsumerState<RealtimeConnectionBadge> createState() => _RealtimeConnectionBadgeState();
}

class _RealtimeConnectionBadgeState extends ConsumerState<RealtimeConnectionBadge> {
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(communityRealtimeNotifierProvider.notifier).connect());
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityRealtimeNotifierProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: state == RealtimeConnectionState.connected ? 0 : 28,
      color: switch (state) {
        RealtimeConnectionState.connected => Colors.transparent,
        RealtimeConnectionState.connecting => Colors.orange.shade100,
        RealtimeConnectionState.reconnecting => Colors.orange.shade100,
        RealtimeConnectionState.disconnected => Colors.red.shade50,
      },
      child: state != RealtimeConnectionState.connected
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12, height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: switch (state) {
                        RealtimeConnectionState.disconnected => Colors.red,
                        _ => Colors.orange,
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    switch (state) {
                      RealtimeConnectionState.connecting => '실시간 연결 중...',
                      RealtimeConnectionState.reconnecting => '재연결 중...',
                      RealtimeConnectionState.disconnected => '연결 끊김 - 탭하여 재연결',
                      _ => '',
                    },
                    style: TextStyle(fontSize: 12, color: state == RealtimeConnectionState.disconnected ? Colors.red : Colors.orange.shade900),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// 실시간 댓글 카운트 배지 (애니메이션)
class RealtimeCommentCountBadge extends StatelessWidget {
  final int count;
  final int? previousCount;

  const RealtimeCommentCountBadge({super.key, required this.count, this.previousCount});

  @override
  Widget build(BuildContext context) {
    final isNew = previousCount != null && count > previousCount!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: Container(
        key: ValueKey(count),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isNew ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$count',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isNew ? Colors.white : Colors.grey.shade700),
        ),
      ),
    );
  }
}

/// Pulse animation for new items
class PulseWidget extends StatefulWidget {
  final Widget child;
  final bool pulsing;
  const PulseWidget({super.key, required this.child, this.pulsing = false});

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(PulseWidget old) {
    super.didUpdateWidget(old);
    if (widget.pulsing && !old.pulsing) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulsing && old.pulsing) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulsing) return widget.child;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(scale: 1.0 + (_animation.value * 0.03), child: child),
      child: widget.child,
    );
  }
}
