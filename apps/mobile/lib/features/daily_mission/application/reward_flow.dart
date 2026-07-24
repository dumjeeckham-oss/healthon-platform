import '../domain/models/reward_result.dart';
import '../domain/models/daily_mission.dart';

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

  //------------------------------------------------------------
  // Mission Reward 실행
  //------------------------------------------------------------

  Future<RewardResult> execute({
    required String userId,
    required DailyMission mission,
    required double totalKm,
  }) async {
    //----------------------------------------------------------
    // 1. Reward 지급
    //----------------------------------------------------------

    await _rewardEngine.claimReward(
      userId: userId,
      rewardType: mission.rewardType,
      rewardValue: mission.rewardValue,
    );

    //----------------------------------------------------------
    // 2. Forest 갱신
    //----------------------------------------------------------

    await _forestRepository.updateDistance(
      userId: userId,
      totalKm: totalKm,
    );

    final forest =
        await _forestRepository.getSummary(userId);

    //----------------------------------------------------------
    // 3. Badge 검사
    //----------------------------------------------------------

    await _badgeRepository.checkAndGrantBadges(
      userId: userId,
      totalKm: totalKm,
      treeLevel: forest.treeLevel,
    );

    //----------------------------------------------------------
    // 4. 나무 해금
    //----------------------------------------------------------

    await _speciesRepository.unlockByLevel(
      userId: userId,
      level: forest.treeLevel,
    );

    //----------------------------------------------------------
    // 5. 결과 반환
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

      oldLevel: forest.treeLevel,

      newLevel: forest.treeLevel,

      levelUp: false,

      badgeUnlocked: false,

      newTreeUnlocked: false,

      gardenUnlocked: false,
    );
  }
}
