import '../domain/models/daily_mission.dart';
import '../domain/models/reward_result.dart';

import 'reward_engine.dart';

import '../../forest/data/forest_repository.dart';
import '../../forest/data/forest_species_repository.dart';
import '../../forest/data/forest_badge_repository.dart';
import '../../forest/data/forest_garden_repository.dart';

class RewardFlow {

  RewardFlow({
    RewardEngine? rewardEngine,
    ForestRepository? forestRepository,
    ForestSpeciesRepository? speciesRepository,
    ForestBadgeRepository? badgeRepository,
    ForestGardenRepository? gardenRepository,
  })  : _rewardEngine =
            rewardEngine ?? RewardEngine(),
        _forestRepository =
            forestRepository ?? ForestRepository(),
        _speciesRepository =
            speciesRepository ??
                ForestSpeciesRepository(),
        _badgeRepository =
            badgeRepository ??
                ForestBadgeRepository(),
        _gardenRepository =
            gardenRepository ??
                ForestGardenRepository();

  final RewardEngine _rewardEngine;

  final ForestRepository _forestRepository;

  final ForestSpeciesRepository
      _speciesRepository;

  final ForestBadgeRepository
      _badgeRepository;

  final ForestGardenRepository
      _gardenRepository;

  ////////////////////////////////////////////////////////////////
  ///
  /// Execute Reward Flow
  ///
  ////////////////////////////////////////////////////////////////

  Future<RewardResult> execute({

    required String userId,

    required DailyMission mission,

    required double totalKm,

  }) async {

    ////////////////////////////////////////////////////////////
    // 1 Mission Reward
    ////////////////////////////////////////////////////////////

    await _rewardEngine.claimReward(

      userId: userId,

      rewardType: mission.rewardType,

      rewardValue: mission.rewardValue,

    );

    ////////////////////////////////////////////////////////////
    // 2 Forest Update
    ////////////////////////////////////////////////////////////

    final oldSummary =
        await _forestRepository.getSummary(
      userId,
    );

    final oldLevel =
        oldSummary.treeLevel;

    await _forestRepository.updateDistance(

      userId: userId,

      totalKm: totalKm,

    );

    final newSummary =
        await _forestRepository.getSummary(
      userId,
    );

    final newLevel =
        newSummary.treeLevel;

    final levelUp =
        newLevel > oldLevel;

      ////////////////////////////////////////////////////////////
    // 3 Tree Unlock
    ////////////////////////////////////////////////////////////

    bool treeUnlocked = false;
    String? unlockedTreeName;

    final unlockedTree =
        await _speciesRepository.unlockByLevel(
      userId: userId,
      level: newLevel,
    );

    if (unlockedTree != null) {
      treeUnlocked = true;
      unlockedTreeName = unlockedTree.name;
    }

    ////////////////////////////////////////////////////////////
    // 4 Badge Check
    ////////////////////////////////////////////////////////////

    bool badgeUnlocked = false;
    String? badgeCode;

    final newBadges =
        await _badgeRepository.checkAndGrantBadges(
      userId: userId,
      totalKm: totalKm,
      treeLevel: newLevel,
    );

    if (newBadges.isNotEmpty) {
      badgeUnlocked = true;
      badgeCode = newBadges.first.code;
    }

    ////////////////////////////////////////////////////////////
    // 5 Garden Unlock
    ////////////////////////////////////////////////////////////

    bool gardenUnlocked = false;
    String? gardenTileId;

    final oldSize = 5 + (oldLevel ~/ 5);
    final newSize = 5 + (newLevel ~/ 5);
    if (newSize > oldSize) {
      await _gardenRepository.unlockTileByLevel(
        userId: userId,
        level: newLevel,
      );
      gardenUnlocked = true;
    }

    ////////////////////////////////////////////////////////////
    // 6 Reward Queue 생성
    ////////////////////////////////////////////////////////////

    final queue = <RewardPresentationType>[];

    if (levelUp) {
      queue.add(
        RewardPresentationType.levelUp,
      );
    }

    if (treeUnlocked) {
      queue.add(
        RewardPresentationType.treeUnlock,
      );
    }

    if (badgeUnlocked) {
      queue.add(
        RewardPresentationType.badge,
      );
    }

    if (gardenUnlocked) {
      queue.add(
        RewardPresentationType.gardenUnlock,
      );
    }

        ////////////////////////////////////////////////////////////
    // 7 RewardResult 생성
    ////////////////////////////////////////////////////////////

    final result = RewardResult(

      //--------------------------------------------------------
      // 기본 보상
      //--------------------------------------------------------

      xp: mission.rewardType.toUpperCase() == "XP"
          ? mission.rewardValue
          : 0,

      leaf: mission.rewardType.toUpperCase() == "LEAF"
          ? mission.rewardValue
          : 0,

      seed: mission.rewardType.toUpperCase() == "SEED"
          ? mission.rewardValue
          : 0,

      coin: mission.rewardType.toUpperCase() == "COIN"
          ? mission.rewardValue
          : 0,

      //--------------------------------------------------------
      // Forest
      //--------------------------------------------------------

      gainedExp: newSummary.treeExp.toInt(),

      oldLevel: oldLevel,

      newLevel: newLevel,

      levelUp: levelUp,

      //--------------------------------------------------------
      // Tree
      //--------------------------------------------------------

      newTreeUnlocked: treeUnlocked,

      treeName: unlockedTreeName,

      //--------------------------------------------------------
      // Badge
      //--------------------------------------------------------

      badgeUnlocked: badgeUnlocked,

      badgeCode: badgeCode,

      //--------------------------------------------------------
      // Garden
      //--------------------------------------------------------

      gardenUnlocked: gardenUnlocked,

      gardenTileId: gardenTileId,

      //--------------------------------------------------------
      // Queue
      //--------------------------------------------------------

      queue: queue,

    );

    ////////////////////////////////////////////////////////////
    // 8 Return
    ////////////////////////////////////////////////////////////

    return result;

  } // execute 끝


}
