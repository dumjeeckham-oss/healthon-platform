import 'package:health/health.dart';

/// ===============================================================
///
/// Health Service
///
/// Android : Health Connect
/// iOS : Apple HealthKit
///
/// 오늘 걸음수를 읽어오는 서비스
///
/// ===============================================================
class HealthService {
  HealthService._();

  static final HealthService instance = HealthService._();

  final Health _health = Health();

  /// 요청할 데이터 타입
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
  ];

  /// --------------------------------------------------------------
  /// Health 권한 요청
  /// --------------------------------------------------------------
  Future<bool> requestPermission() async {
    final hasPermission = await _health.hasPermissions(_types);

    if (hasPermission == true) {
      return true;
    }

    final granted = await _health.requestAuthorization(
      _types,
      permissions: [
        HealthDataAccess.READ,
      ],
    );

    return granted;
  }

  /// --------------------------------------------------------------
  /// 오늘 걸음수
  /// --------------------------------------------------------------
  Future<int> getTodaySteps() async {
    final granted = await requestPermission();

    if (!granted) {
      throw Exception("Health 권한이 허용되지 않았습니다.");
    }

    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final end = now;

    try {
      final steps = await _health.getTotalStepsInInterval(
        start,
        end,
      );

      return steps ?? 0;
    } catch (e) {
      throw Exception(
        "걸음수 조회 실패 : $e",
      );
    }
  }

  /// --------------------------------------------------------------
  /// 오늘 날짜
  /// --------------------------------------------------------------
  DateTime get today {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
    );
  }
}
