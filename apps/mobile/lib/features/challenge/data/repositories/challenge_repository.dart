import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeRepository {
  ChallengeRepository();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// ----------------------------------------------------------
  /// 현재 누적거리 조회
  /// ----------------------------------------------------------
  Future<double> getTotalDistance(String userId) async {
    final data = await _supabase
        .from('challenge_progress')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      return 0;
    }

    return (data['total_distance'] ?? 0).toDouble();
  }

  /// ----------------------------------------------------------
  /// 진행률 조회
  /// ----------------------------------------------------------
  Future<double> getProgress(String userId) async {
    final distance = await getTotalDistance(userId);

    return (distance / 100).clamp(0.0, 1.0);
  }

  /// ----------------------------------------------------------
  /// 남은 거리
  /// ----------------------------------------------------------
  Future<double> getRemainingDistance(String userId) async {
    final distance = await getTotalDistance(userId);

    final remain = 100 - distance;

    return remain < 0 ? 0 : remain;
  }

  /// ----------------------------------------------------------
  /// 완료 여부
  /// ----------------------------------------------------------
  Future<bool> isCompleted(String userId) async {
    final distance = await getTotalDistance(userId);

    return distance >= 100;
  }

  /// ----------------------------------------------------------
  /// 누적거리 업데이트
  /// ----------------------------------------------------------
  Future<void> updateProgress({
    required String userId,
    required double totalDistance,
  }) async {
    final completed = totalDistance >= 100;

    await _supabase
        .from('challenge_progress')
        .upsert({
          'user_id': userId,
          'total_distance': totalDistance,
          'progress': totalDistance / 100,
          'completed': completed,
          'updated_at': DateTime.now().toIso8601String(),
        });
  }
}
