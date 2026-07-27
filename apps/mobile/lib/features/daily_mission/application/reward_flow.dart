import '../domain/models/daily_mission.dart';
import '../domain/models/reward_result.dart';

import 'reward_engine.dart';

import '../../forest/data/forest_repository.dart';
import '../../forest/data/forest_badge_repository.dart';
import '../../forest/data/forest_species_repository.dart';

class RewardFlow {
  RewardFlow({
    RewardEngine? rewardEngine,
    ForestRepository? forestRepository,
    ForestBadgeRepository? badgeRepository,
    ForestSpeciesRepository? speciesRepository,
  })  : _rewardEngine = rewardEngine ?? RewardEngine(),
        _forestRepository = forestRepository ?? ForestRepository(),
        _badgeRepository =
            badgeRepository ?? ForestBadgeRepository(),
        _speciesRepository =
            speciesRepository ?? ForestSpeciesRepository();

  final RewardEngine _rewardEngine;
  final ForestRepository _forestRepository;
  final ForestBadgeRepository _badgeRepository;
  final ForestSpeciesRepository _speciesRepository;

  //----------------------------------------------------------
  // Mission Reward 실행
  //----------------------------------------------------------

  Future<RewardResult> execute({
    required String userId,
    required DailyMission mission,
    required double totalKm,
  }) async {

    //----------------------------------------------------------
    // 현재 Forest 상태 저장
    //----------------------------------------------------------

    final beforeForest =
        await _forestRepository.getSummary(userId);

    final oldLevel = beforeForest.treeLevel;

    //----------------------------------------------------------
    // Reward 지급
    //----------------------------------------------------------

    await _rewardEngine.claimReward(
      userId: userId,
      rewardType: mission.rewardType,
      rewardValue: mission.rewardValue,
    );

    //----------------------------------------------------------
    // Forest 업데이트
    //----------------------------------------------------------

    await _forestRepository.updateDistance(
      userId: userId,
      totalKm: totalKm,
    );

    //----------------------------------------------------------
    // 업데이트된 Forest 다시 조회
    //----------------------------------------------------------

    final afterForest =
        await _forestRepository.getSummary(userId);

    final newLevel = afterForest.treeLevel;

    final levelUp = newLevel > oldLevel;

    //----------------------------------------------------------
    // Badge 검사
    //----------------------------------------------------------

    await _badgeRepository.checkAndGrantBadges(
      userId: userId,
      totalKm: totalKm,
      treeLevel: newLevel,
    );

    //----------------------------------------------------------
    // Tree Unlock
    //----------------------------------------------------------

    await _speciesRepository.unlockByLevel(
      userId: userId,
      level: newLevel,
    );

    //----------------------------------------------------------
    // Presentation Queue 생성
    //----------------------------------------------------------

    final queue = <RewardPresentationType>[];

    if (levelUp) {
      queue.add(
        RewardPresentationType.levelUp,
      );
    }

    //----------------------------------------------------------
    // TODO
    // 이후 Badge, Tree, Garden Unlock 검사 후
    // queue.add(...)
    //----------------------------------------------------------

    //----------------------------------------------------------
    // RewardResult 반환
    //----------------------------------------------------------

    return RewardResult(
      xp: mission.rewardType == "XP"
          ? mission.rewardValue
          : 0,

      leaf: mission.rewardType == "LEAF"
          ? mission.rewardValue
          : 0,

      seed: mission.rewardType == "SEED"
          ? mission.rewardValue
          : 0,

      coin: mission.rewardType == "COIN"
          ? mission.rewardValue
          : 0,

      gainedExp: mission.rewardValue,

      oldLevel: oldLevel,

      newLevel: newLevel,

      levelUp: levelUp,

      badgeUnlocked: false,

      badgeCode: null,

      newTreeUnlocked: false,

      treeName: null,

      gardenUnlocked: false,

      gardenTileId: null,

      queue: queue,
    );
  }
}
