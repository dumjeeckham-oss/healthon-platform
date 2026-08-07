/// ===============================================================
/// HealthON — Push Notification Service
///
/// FCM 토큰 관리 + flutter_local_notifications + Supabase 동기화
/// ===============================================================

library;

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ===============================================================
/// RemoteMessage handler type
/// ===============================================================

typedef OnPushMessageReceived = void Function(RemoteMessage message);
typedef OnPushMessageOpened = void Function(RemoteMessage message);

/// ===============================================================
/// PushNotificationService
/// ===============================================================

class PushNotificationService {
  final SupabaseClient _client;

  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  OnPushMessageReceived? onMessageReceived;
  OnPushMessageOpened? onMessageOpened;

  // 초기화 상태
  bool _initialized = false;
  bool get isInitialized => _initialized;

  // 마지막 FCM 토큰
  String? _lastToken;
  String? get fcmToken => _lastToken;

  PushNotificationService(this._client);

  // =============================================================
  // Initialize
  // =============================================================

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // FCM 초기화
      _messaging = FirebaseMessaging.instance;

      // iOS 권한
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _messaging!.requestPermission(
          alert: true, badge: true, sound: true, provisional: false,
        );
      }

      // Local Notifications 초기화
      await _initLocalNotifications();

      // FCM 토큰 획득
      _lastToken = await _messaging!.getToken();
      debugPrint('FCM Token: $_lastToken');

      // 토큰 갱신 리스너
      _messaging!.onTokenRefresh.listen((newToken) {
        _lastToken = newToken;
        debugPrint('FCM Token Refreshed: $newToken');
        _upsertToken(newToken);
      });

      // 포그라운드 메시지
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // 백그라운드 탭
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      // 종료 상태에서 탭
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _onMessageOpened(initialMessage);
      }

      _initialized = true;
      debugPrint('PushNotificationService: initialized');
    } catch (e) {
      debugPrint('PushNotificationService init error: $e');
    }
  }

  // =============================================================
  // Token Management
  // =============================================================

  /// 현재 사용자의 FCM 토큰을 Supabase에 등록
  Future<void> registerCurrentUserToken() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || _lastToken == null) return;
    await _upsertToken(_lastToken!);
  }

  Future<void> _upsertToken(String token) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 기존 토큰 비활성화 (다른 디바이스)
      await _client.from('push_tokens').update({'is_active': false, 'updated_at': DateTime.now().toUtc().toIso8601String()}).eq('user_id', userId).neq('fcm_token', token);

      // 현재 토큰 upsert
      await _client.from('push_tokens').upsert({
        'user_id': userId,
        'fcm_token': token,
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : defaultTargetPlatform == TargetPlatform.android ? 'android' : 'web',
        'is_active': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id, fcm_token');
    } catch (e) {
      debugPrint('PushNotificationService upsertToken: $e');
    }
  }

  /// 현재 사용자 토큰 제거 (로그아웃 시)
  Future<void> removeCurrentUserToken() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _client.from('push_tokens').update({'is_active': false, 'updated_at': DateTime.now().toUtc().toIso8601String()}).eq('user_id', userId);
    } catch (_) {}
  }

  // =============================================================
  // Subscribe / Unsubscribe Topics
  // =============================================================

  Future<void> subscribeToTopic(String topic) async {
    await _messaging?.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging?.unsubscribeFromTopic(topic);
  }

  // =============================================================
  // Local Notification
  // =============================================================

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'healthon_channel',
      'HealthON 알림',
      channelDescription: '건강ON 푸시 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotifications.show(
      id, title, body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // =============================================================
  // Handlers
  // =============================================================

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('PushNotificationService: foreground message ${message.messageId}');
    // 포그라운드에서도 로컬 알림 표시
    showLocalNotification(
      id: message.hashCode,
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      payload: _encodePayload(message.data),
    );
    onMessageReceived?.call(message);

    // Supabase 큐 상태 업데이트
    _markQueueSent(message.data);
  }

  void _onMessageOpened(RemoteMessage message) {
    debugPrint('PushNotificationService: message opened ${message.messageId}');
    onMessageOpened?.call(message);
  }

  Future<void> _onLocalNotificationTap(NotificationResponse response) async {
    debugPrint('PushNotificationService: local notification tapped ${response.payload}');
    // payload 기반 deep link 처리
  }

  // =============================================================
  // Queue Management
  // =============================================================

  Future<void> _markQueueSent(Map<String, dynamic> data) async {
    final queueId = data['queue_id'];
    if (queueId == null) return;
    try {
      await _client.from('push_notification_queue').update({
        'status': 'sent',
        'sent_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', queueId);
    } catch (_) {}
  }

  String _encodePayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  // =============================================================
  // Dispose
  // =============================================================

  void dispose() {
    _initialized = false;
    _lastToken = null;
  }
}
