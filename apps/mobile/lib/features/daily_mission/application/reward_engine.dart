import '../../reward/data/reward_repository.dart';

/// ===============================================================
///
/// HealthON Reward Engine
///
/// 미션 보상 지급
/// 경제 시스템(Core Economy)
///
/// ===============================================================

class RewardEngine {
  RewardEngine({
    RewardRepository? repository,
  }) : _repository = repository ?? RewardRepository();

  final RewardRepository _repository;

  //----------------------------------------------------------
  // Reward 지급
  //----------------------------------------------------------

  Future<void> claimReward({
    required String userId,
    required String rewardType,
    required int rewardValue,
  }) async {
    switch (rewardType.toUpperCase()) {
      case "XP":
        await _repository.addXp(
          userId: userId,
          amount: rewardValue,
        );
        break;

      case "LEAF":
        await _repository.addLeaf(
          userId: userId,
          amount: rewardValue,
        );
        break;

      case "SEED":
        await _repository.addSeed(
          userId: userId,
          amount: rewardValue,
        );
        break;

      case "COIN":
        await _repository.addCoin(
          userId: userId,
          amount: rewardValue,
        );
        break;

      default:
        break;
    }
  }

  //----------------------------------------------------------
  // 여러 보상 지급
  //----------------------------------------------------------

  Future<void> claimRewards({
    required String userId,
    int xp = 0,
    int leaf = 0,
    int seed = 0,
    int coin = 0,
  }) async {
    await _repository.addReward(
      userId: userId,
      xp: xp,
      leaf: leaf,
      seed: seed,
      coin: coin,
    );
  }

  //----------------------------------------------------------
  // 현재 XP
  //----------------------------------------------------------

  Future<int> currentXp(
    String userId,
  ) {
    return _repository.getXp(userId);
  }

  //----------------------------------------------------------
  // 현재 Leaf
  //----------------------------------------------------------

  Future<int> currentLeaf(
    String userId,
  ) {
    return _repository.getLeaf(userId);
  }

  //----------------------------------------------------------
  // 현재 Seed
  //----------------------------------------------------------

  Future<int> currentSeed(
    String userId,
  ) {
    return _repository.getSeed(userId);
  }

  //----------------------------------------------------------
  // 현재 Coin
  //----------------------------------------------------------

  Future<int> currentCoin(
    String userId,
  ) {
    return _repository.getCoin(userId);
  }

  //----------------------------------------------------------
  // Leaf 차감
  //----------------------------------------------------------

  Future<bool> spendLeaf({
    required String userId,
    required int amount,
  }) {
    return _repository.spendLeaf(
      userId: userId,
      amount: amount,
    );
  }

  //----------------------------------------------------------
  // Seed 차감
  //----------------------------------------------------------

  Future<bool> spendSeed({
    required String userId,
    required int amount,
  }) {
    return _repository.spendSeed(
      userId: userId,
      amount: amount,
    );
  }

  //----------------------------------------------------------
  // Coin 차감
  //----------------------------------------------------------

  Future<bool> spendCoin({
    required String userId,
    required int amount,
  }) {
    return _repository.spendCoin(
      userId: userId,
      amount: amount,
    );
  }

  //----------------------------------------------------------
  // 모든 재화 조회
  //----------------------------------------------------------

  Future<Map<String, dynamic>> inventory(
    String userId,
  ) {
    return _repository.getRewards(userId);
  }

  //----------------------------------------------------------
  // 관리자 초기화
  //----------------------------------------------------------

  Future<void> reset(
    String userId,
  ) {
    return _repository.reset(userId);
  }
}
