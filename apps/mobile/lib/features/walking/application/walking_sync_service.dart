import '../../challenge/data/repositories/challenge_repository.dart';
import '../../forest/data/forest_repository.dart';
import '../data/step_repository_impl.dart';

class WalkingSyncService {
  WalkingSyncService({
    StepRepositoryImpl? stepRepository,
    ChallengeRepository? challengeRepository,
    ForestRepository? forestRepository,
  })  : _stepRepository = stepRepository ?? StepRepositoryImpl(),
        _challengeRepository =
            challengeRepository ?? ChallengeRepository(),
        _forestRepository =
            forestRepository ?? ForestRepository();

  final StepRepositoryImpl _stepRepository;
  final ChallengeRepository _challengeRepository;
  final ForestRepository _forestRepository;

  //----------------------------------------------------------
  // 오늘 걸음 → Challenge + Forest 동기화
  //----------------------------------------------------------

  Future<void> syncToday(String userId) async {
    final totalDistance =
        await _stepRepository.getTotalDistance(userId);

    // Challenge
    await _challengeRepository.updateProgress(
      userId: userId,
      totalDistance: totalDistance,
    );

    // Forest
    await _forestRepository.updateDistance(
      userId: userId,
      totalKm: totalDistance,
    );
  }

  //----------------------------------------------------------
  // 전체 재동기화
  //----------------------------------------------------------

  Future<void> syncAll(String userId) async {
    final totalDistance =
        await _stepRepository.getTotalDistance(userId);

    await _challengeRepository.updateProgress(
      userId: userId,
      totalDistance: totalDistance,
    );

    await _forestRepository.updateDistance(
      userId: userId,
      totalKm: totalDistance,
    );
  }
}
