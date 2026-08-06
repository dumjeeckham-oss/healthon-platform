/// ===============================================================
/// HealthON — Push Initialization Service
///
/// 앱 시작 시 FCM 초기화 + 토큰 등록 + 딥링크 처리
/// main.dart 또는 app.dart에서 호출
/// ===============================================================

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'push_notification_service.dart';
import 'push_provider.dart';

/// ===============================================================
/// 앱 시작 시 1회 호출
/// ===============================================================

Future<void> initializePushNotifications(WidgetRef ref) async {
  final service = ref.read(pushServiceProvider);

  // FCM + Local Notifications 초기화
  await service.initialize();

  // 현재 사용자 토큰 등록
  await service.registerCurrentUserToken();

  // 딥링크 핸들러 설정
  service.onMessageOpened = (RemoteMessage message) {
    _handleDeepLink(ref, message.data);
  };

  // 푸시 설정 로드
  ref.read(pushSettingsProvider.notifier).load();
}

/// ===============================================================
/// 로그인 성공 시 호출
/// ===============================================================

Future<void> onUserLoggedIn(WidgetRef ref) async {
  final service = ref.read(pushServiceProvider);

  // 토큰 등록
  await service.registerCurrentUserToken();

  // 토픽 구독
  await service.subscribeToTopic('all_users');
  await service.subscribeToTopic('notice');
  await service.subscribeToTopic('challenge');

  // 푸시 설정 로드
  ref.read(pushSettingsProvider.notifier).load();
}

/// ===============================================================
/// 로그아웃 시 호출
/// ===============================================================

Future<void> onUserLoggedOut(WidgetRef ref) async {
  final service = ref.read(pushServiceProvider);

  // 토픽 구독 해제
  await service.unsubscribeFromTopic('all_users');
  await service.unsubscribeFromTopic('notice');
  await service.unsubscribeFromTopic('challenge');

  // 토큰 제거
  await service.removeCurrentUserToken();
}

/// ===============================================================
/// Deep Link Router
/// ===============================================================

void _handleDeepLink(WidgetRef ref, Map<String, dynamic> data) {
  final category = data['category'] as String?;
  final router = GoRouter.of(ref.context);

  switch (category) {
    case 'notice':
      final noticeId = data['notice_id'] ?? data['noticeId'];
      if (noticeId != null) {
        router.go('/community');
      }
      break;
    case 'challenge':
      router.go('/home');
      break;
    case 'mission':
      router.go('/home');
      break;
    case 'community':
      final postId = data['post_id'] ?? data['postId'];
      if (postId != null) {
        router.go('/community');
      }
      break;
    case 'report':
      router.go('/admin/reports');
      break;
    default:
      router.go('/home');
  }
}
