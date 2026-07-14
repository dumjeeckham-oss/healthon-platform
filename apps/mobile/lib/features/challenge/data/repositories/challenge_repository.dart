import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/challenge_summary.dart';

class ChallengeRepository {
  ChallengeRepository();

  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================================
  // 현재 누적거리 조회
  // ==========================================================

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

  // ==========================================================
  // 진행률
  // ==========================================================

  Future<double> getProgress(String userId) async {
    final distance = await getTotalDistance(userId);

    return (distance / 100).clamp(0.0, 1.0);
  }

  // ==========================================================
  // 남은 거리
  // ==========================================================

  Future<double> getRemainingDistance(String userId) async {
    final distance = await getTotalDistance(userId);

    final remain = 100 - distance;

    return remain < 0 ? 0 : remain;
  }

  // ==========================================================
  // 완료 여부
  // ==========================================================

  Future<bool> isCompleted(String userId) async {
    final distance = await getTotalDistance(userId);

    return distance >= 100;
  }

  // ==========================================================
  // Dashboard에서 사용할 Summary
  // ==========================================================

  Future<ChallengeSummary> getSummary(String userId) async {
    final currentKm = await getTotalDistance(userId);

    const goalKm = 100.0;

    final progress = (currentKm / goalKm).clamp(0.0, 1.0);

    final remainingKm = (goalKm - currentKm).clamp(0.0, goalKm);

    const todayGoal = 3.0;

    final remainDays =
        todayGoal == 0 ? 0 : (remainingKm / todayGoal).ceil();

    final finishDate =
        DateTime.now().add(Duration(days: remainDays));

    String cheerMessage;

    if (progress >= 1.0) {
      cheerMessage = "🎉 100K 완주를 축하합니다!";
    } else if (progress >= 0.8) {
      cheerMessage = "🔥 완주가 눈앞입니다!";
    } else if (progress >= 0.5) {
      cheerMessage = "👏 절반을 넘었습니다!";
    } else if (progress >= 0.2) {
      cheerMessage = "💪 좋은 페이스입니다!";
    } else {
      cheerMessage = "🚶 첫걸음을 응원합니다!";
    }

    return ChallengeSummary(
      currentKm: currentKm,
      goalKm: goalKm,
      progress: progress,
      todayGoal: todayGoal,
      remainingKm: remainingKm,
      expectedFinish:
          "${finishDate.year}-${finishDate.month.toString().padLeft(2, '0')}-${finishDate.day.toString().padLeft(2, '0')}",
      cheerMessage: cheerMessage,
    );
  }

  // ==========================================================
  // 진행상황 저장
  // ==========================================================

  Future<void> updateProgress({
    required String userId,
    required double totalDistance,
  }) async {
    final completed = totalDistance >= 100;

    await _supabase.from('challenge_progress').upsert({
      'user_id': userId,
      'total_distance': totalDistance,
      'progress': totalDistance / 100,
      'completed': completed,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
