import '../../core/session/user_session.dart';
import '../storage/local_step_cache.dart';
import '../../features/walking/application/sync_steps.dart';

class HealthService {
  final LocalStepCache cache;
  final SyncSteps syncSteps;

  HealthService({
    required this.cache,
    required this.syncSteps,
  });

  /// 걸음 누적 (실시간 호출용)
  Future<void> addSteps(int steps) async {
    await cache.addSteps(steps);
  }

  /// 서버 동기화 (주기 실행)
  Future<void> sync() async {
    final userId = UserSession.userId;

    // 로그인 안 되어 있으면 절대 동기화 안 함
    if (userId == null) return;

    final steps = await cache.getTodaySteps();

    if (steps <= 0) return;

    final distanceKm = steps * 0.0007;

    await syncSteps.execute(
      userId: userId,
      steps: steps,
      distanceKm: distanceKm,
    );
  }
}
