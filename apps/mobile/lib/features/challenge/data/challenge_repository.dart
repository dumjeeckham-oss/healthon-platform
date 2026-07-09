import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/challenge_progress.dart';

/// ===============================================================
///
/// Challenge Repository
///
/// step_daily
///
/// ↓
///
/// 누적 걸음수 계산
///
/// ↓
///
/// 50K / 100K / 200K
///
/// ===============================================================
class ChallengeRepository {
  ChallengeRepository();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  /// --------------------------------------------------------------
  /// 현재 로그인 사용자 챌린지 진행률
  /// --------------------------------------------------------------
  Future<ChallengeProgress> getProgress() async {
    final authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      return ChallengeProgress.fromTotalSteps(0);
    }

    final rows = await _supabase
        .from('step_daily')
        .select('steps')
        .eq('user_id', authUser.id);

    int totalSteps = 0;

    for (final row in rows) {
      totalSteps += (row['steps'] ?? 0) as int;
    }

    return ChallengeProgress.fromTotalSteps(
      totalSteps,
    );
  }

  /// --------------------------------------------------------------
  /// 누적 걸음수
  /// --------------------------------------------------------------
  Future<int> getTotalSteps() async {
    final progress = await getProgress();

    return progress.totalSteps;
  }

  /// --------------------------------------------------------------
  /// 50K 완료 여부
  /// --------------------------------------------------------------
  Future<bool> is50KCompleted() async {
    final progress = await getProgress();

    return progress.completed50K;
  }

  /// --------------------------------------------------------------
  /// 100K 완료 여부
  /// --------------------------------------------------------------
  Future<bool> is100KCompleted() async {
    final progress = await getProgress();

    return progress.completed100K;
  }

  /// --------------------------------------------------------------
  /// 200K 완료 여부
  /// --------------------------------------------------------------
  Future<bool> is200KCompleted() async {
    final progress = await getProgress();

    return progress.completed200K;
  }

  /// --------------------------------------------------------------
  /// 남은 걸음수
  /// --------------------------------------------------------------
  Future<int> remainSteps() async {
    final progress = await getProgress();

    return progress.remainSteps;
  }
}
