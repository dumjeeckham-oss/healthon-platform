import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../notification_provider.dart';

/// ===============================================================
/// HealthON — Notification List Screen
/// ===============================================================

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(recentNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(markAllReadProvider);
            },
            child: const Text('전체 읽음'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('새로운 알림이 없습니다', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const Divider(height: 0.5),
            itemBuilder: (context, index) {
              final item = notifications[index];
              return _NotificationTile(
                title: item['title'] as String? ?? '',
                body: item['body'] as String? ?? '',
                type: item['type'] as String? ?? '',
                isRead: item['is_read'] as bool? ?? false,
                createdAt: item['created_at'] != null
                    ? DateTime.parse(item['created_at'] as String)
                    : null,
                onTap: () {
                  ref.read(notificationEngineProvider).markAsRead(item['id'] as String);
                  ref.invalidate(unreadNotificationCountProvider);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('알림을 불러오지 못했습니다\n$e')),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.createdAt,
    this.onTap,
  });

  IconData _typeIcon() {
    switch (type) {
      case 'walking':
        return Icons.directions_walk;
      case 'forest':
        return Icons.forest;
      case 'challenge':
        return Icons.emoji_events;
      case 'ranking':
        return Icons.leaderboard;
      case 'badge':
        return Icons.verified;
      case 'social':
        return Icons.people;
      default:
        return Icons.notifications;
    }
  }

  Color _typeColor() {
    switch (type) {
      case 'walking':
        return const Color(0xFF2E7D32);
      case 'forest':
        return Colors.green.shade700;
      case 'challenge':
        return Colors.orange;
      case 'ranking':
        return Colors.amber.shade700;
      case 'badge':
        return Colors.purple;
      case 'social':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? null : const Color(0xFF2E7D32).withValues(alpha: 0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _typeColor().withValues(alpha: 0.1),
              child: Icon(_typeIcon(), size: 20, color: _typeColor()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (createdAt != null) ...[
              const SizedBox(width: 8),
              Text(
                _formatTime(createdAt!),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return DateFormat('MM/dd').format(dt);
  }
}
