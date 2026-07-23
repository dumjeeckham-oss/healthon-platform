import '../../challenge/data/repositories/challenge_repository.dart';
import '../../forest/data/forest_repository.dart';
import '../../forest/data/forest_badge_repository.dart';
import '../data/step_repository_impl.dart';

class WalkingSyncService {
  WalkingSyncService({
    StepRepositoryImpl? stepRepository,
    ChallengeRepository? challengeRepository,
    ForestRepository? forestRepository,
    ForestBadgeRepository? badgeRepository,
  })  : _stepRepository = stepRepository ?? StepRepositoryImpl(),
        _challengeRepository =
            challengeRepository ?? ChallengeRepository(),
        _forestRepository =
            forestRepository ?? ForestRepository(),
        _badgeRepository =
            badgeRepository ?? ForestBadgeRepository();

  final StepRepositoryImpl _stepRepository;
  final ChallengeRepository _challengeRepository;
  final ForestRepository _forestRepository;
  final ForestBadgeRepository _badgeRepository;

  //============================================================
  // 오늘 데이터 동기화
  //============================================================
  Future<void> syncToday(String userId) async {
    final totalDistance =
        await _stepRepository.getTotalDistance(userId);

    // Challenge 진행률 업데이트
    await _challengeRepository.updateProgress(
      userId: userId,
      totalDistance: totalDistance,
    );

    // Forest 성장
    await _forestRepository.updateDistance(
      userId: userId,
      totalKm: totalDistance,
    );

    // Forest Badge 지급
    await _badgeRepository.checkAndUnlock(
      userId: userId,
      totalKm: totalDistance,
    );
  }

  //============================================================
  // 전체 재동기화
  //============================================================
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

    await _badgeRepository.checkAndUnlock(
      userId: userId,
      totalKm: totalDistance,
    );
  }
}
