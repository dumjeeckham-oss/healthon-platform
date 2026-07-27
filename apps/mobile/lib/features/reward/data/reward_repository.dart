import 'package:supabase_flutter/supabase_flutter.dart';

/// ===============================================================
///
/// HealthON Reward Repository
///
/// XP / Leaf / Seed / Coin 관리
///
/// Table
/// user_rewards
///
/// ===============================================================

class RewardRepository {
  RewardRepository();

  final SupabaseClient _client = Supabase.instance.client;

  static const String _table = "user_rewards";

  /// ===============================================================
  /// 최초 생성
  /// ===============================================================

  Future<void> initialize(String userId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq("user_id", userId)
        .maybeSingle();

    if (data != null) return;

    await _client.from(_table).insert({
      "user_id": userId,
      "xp": 0,
      "leaf": 0,
      "seed": 0,
      "coin": 0,
    });
  }

  /// ===============================================================
  /// 전체 조회
  /// ===============================================================

  Future<Map<String, dynamic>> getRewards(
    String userId,
  ) async {
    await initialize(userId);

    final result = await _client
        .from(_table)
        .select()
        .eq("user_id", userId)
        .single();

    return result;
  }

  /// ===============================================================
  /// XP
  /// ===============================================================

  Future<int> getXp(
    String userId,
  ) async {
    final data = await getRewards(userId);

    return (data["xp"] ?? 0) as int;
  }

  Future<void> addXp({
    required String userId,
    required int amount,
  }) async {
    final current = await getXp(userId);

    await _client.from(_table).update({
      "xp": current + amount,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq(
      "user_id",
      userId,
    );
  }

  /// ===============================================================
  /// Leaf
  /// ===============================================================

  Future<int> getLeaf(
    String userId,
  ) async {
    final data = await getRewards(userId);

    return (data["leaf"] ?? 0) as int;
  }

  Future<void> addLeaf({
    required String userId,
    required int amount,
  }) async {
    final current = await getLeaf(userId);

    await _client.from(_table).update({
      "leaf": current + amount,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq(
      "user_id",
      userId,
    );
  }

  /// ===============================================================
  /// Seed
  /// ===============================================================

  Future<int> getSeed(
    String userId,
  ) async {
    final data = await getRewards(userId);

    return (data["seed"] ?? 0) as int;
  }

  Future<void> addSeed({
    required String userId,
    required int amount,
  }) async {
    final current = await getSeed(userId);

    await _client.from(_table).update({
      "seed": current + amount,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq(
      "user_id",
      userId,
    );
  }

  /// ===============================================================
  /// Coin
  /// ===============================================================

  Future<int> getCoin(
    String userId,
  ) async {
    final data = await getRewards(userId);

    return (data["coin"] ?? 0) as int;
  }

  Future<void> addCoin({
    required String userId,
    required int amount,
  }) async {
    final current = await getCoin(userId);

    await _client.from(_table).update({
      "coin": current + amount,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq(
      "user_id",
      userId,
    );
  }

  /// ===============================================================
  /// 통합 보상 지급
  /// ===============================================================

  Future<void> addReward({
    required String userId,
    int xp = 0,
    int leaf = 0,
    int seed = 0,
    int coin = 0,
  }) async {
    await initialize(userId);

    final current = await getRewards(userId);

    await _client.from(_table).update({
      "xp": (current["xp"] ?? 0) + xp,
      "leaf": (current["leaf"] ?? 0) + leaf,
      "seed": (current["seed"] ?? 0) + seed,
      "coin": (current["coin"] ?? 0) + coin,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq(
      "user_id",
      userId,
    );
  }

  /// ===============================================================
  /// 재화 차감
  /// ===============================================================

  Future<bool> spendLeaf({
    required String userId,
    required int amount,
  }) async {
    final current = await getLeaf(userId);

    if (current < amount) {
      return false;
    }

    await _client.from(_table).update({
      "leaf": current - amount,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq(
      "user_id",
      userId,
    );

    return true;
  }

  Future<bool> spendSeed({
    required String userId,
    required int amount,
  }) async {
    final current = await getSeed(userId);

    if (current < amount) {
      return false;
    }

    await _client.from(_table).update({
      "seed": current - amount,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq(
      "user_id",
      userId,
    );

    return true;
  }

  Future<bool> spendCoin({
    required String userId,
    required int amount,
  }) async {
    final current = await getCoin(userId);

    if (current < amount) {
      return false;
    }

    await _client.from(_table).update({
      "coin": current - amount,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq(
      "user_id",
      userId,
    );

    return true;
  }

  /// ===============================================================
  /// 초기화 (관리자용)
  /// ===============================================================

  Future<void> reset(
    String userId,
  ) async {
    await _client.from(_table).update({
      "xp": 0,
      "leaf": 0,
      "seed": 0,
      "coin": 0,
      "updated_at": DateTime.now().toIso8601String(),
    }).eq(
      "user_id",
      userId,
    );
  }
}
