import '../../challenge/data/repositories/challenge_repository.dart';
import '../data/step_repository_impl.dart';

class WalkingSyncService {
  WalkingSyncService({
    StepRepositoryImpl? stepRepository,
    ChallengeRepository? challengeRepository,
  })  : _stepRepository = stepRepository ?? StepRepositoryImpl(),
        _challengeRepository =
            challengeRepository ?? ChallengeRepository();

  final StepRepositoryImpl _stepRepository;
  final ChallengeRepository _challengeRepository;

  /// ----------------------------------------------------------
  /// 오늘 걸음수를 Challenge에 반영
  /// ----------------------------------------------------------
  Future<void> syncToday(String userId) async {
    final totalDistance =
         await _stepRepository.getTotalDistance(userId);

   await _challengeRepository.updateProgress(
    userId: userId,
    totalDistance: totalDistance,
    );
  }

  /// ----------------------------------------------------------
  /// step_daily 누적거리 기준으로 Challenge 재계산
  /// ----------------------------------------------------------
  Future<void> syncAll(String userId) async {
    final weeklySteps =
        await _stepRepository.getWeeklySteps(userId);

    final totalSteps =
        weeklySteps.fold<int>(0, (sum, e) => sum + e);

    final totalDistance = totalSteps * 0.0007;

    await _challengeRepository.updateProgress(
      userId: userId,
      totalDistance: totalDistance,
    );
  }
}
