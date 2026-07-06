import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// ===============================================================
///
/// HealthON Connectivity Service
///
/// 인터넷 연결 상태 관리
///
/// - WiFi
/// - Mobile
/// - Ethernet
/// - VPN
/// - Offline
///
/// ===============================================================

enum NetworkStatus {
  connected,
  disconnected,
}

class ConnectivityService {
  ConnectivityService._();

  static final Connectivity _connectivity = Connectivity();

  static final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static NetworkStatus _currentStatus = NetworkStatus.disconnected;

  static NetworkStatus get currentStatus => _currentStatus;

  static bool get isConnected =>
      _currentStatus == NetworkStatus.connected;

  static Stream<NetworkStatus> get stream => _controller.stream;

  /// 초기화
  static Future<void> initialize() async {
    await _checkCurrentStatus();

    _subscription ??=
        _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  /// 현재 상태 확인
  static Future<void> _checkCurrentStatus() async {
    final results = await _connectivity.checkConnectivity();

    _updateStatus(results);
  }

  /// 변경 감지
  static void _onConnectivityChanged(
    List<ConnectivityResult> results,
  ) {
    _updateStatus(results);
  }

  static void _updateStatus(
    List<ConnectivityResult> results,
  ) {
    final connected = results.any(
      (result) =>
          result != ConnectivityResult.none,
    );

    final newStatus = connected
        ? NetworkStatus.connected
        : NetworkStatus.disconnected;

    if (newStatus == _currentStatus) {
      return;
    }

    _currentStatus = newStatus;

    debugPrint(
      '🌐 Connectivity : $_currentStatus',
    );

    _controller.add(_currentStatus);
  }

  /// 인터넷 확인
  static Future<bool> hasConnection() async {
    await _checkCurrentStatus();

    return isConnected;
  }

  /// 종료
  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;

    await _controller.close();
  }
}
