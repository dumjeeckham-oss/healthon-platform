import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_engine.dart';

// ===============================================================
// Supabase Client
// ===============================================================

final notificationSupabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ===============================================================
// Notification Engine
// ===============================================================

final notificationEngineProvider = Provider<NotificationEngine>(
  (ref) => NotificationEngine(ref.watch(notificationSupabaseProvider)),
);

// ===============================================================
// 미읽음 알림 개수 (배지용)
// ===============================================================

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return 0;

  return ref.watch(notificationEngineProvider).getUnreadCount(userId);
});

// ===============================================================
// 최근 알림 목록
// ===============================================================

final recentNotificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];

  return ref.watch(notificationEngineProvider).getRecent(userId);
});

// ===============================================================
// 알림 전체 읽음 처리
// ===============================================================

final markAllReadProvider = FutureProvider<void>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  final engine = ref.watch(notificationEngineProvider);
  await engine.markAllAsRead(userId);
  ref.invalidate(unreadNotificationCountProvider);
  ref.invalidate(recentNotificationsProvider);
});
