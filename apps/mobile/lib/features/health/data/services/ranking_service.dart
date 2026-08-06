/// ===============================================================
/// HealthON — Ranking Service (Supabase SQL 기반) v2 — Social Engine 연동
///
/// health_daily.steps 합계 → 주간/월간/전체 랭킹
/// 랭킹 변동 시 ActivityEvent 자동 발생
/// ===============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../social_engine/activity_engine.dart';

class RankingResult {
  final String userId;
  final String userName;
  final int totalSteps;
  final double totalDistance;
  final int rank;

  const RankingResult({
    required this.userId,
    required this.userName,
    required this.totalSteps,
    required this.totalDistance,
    required this.rank,
  });
}

class RankingService {
  final SupabaseClient _client;

  RankingService(this._client);

  // =============================================================
  // 랭킹 조회 + 변동 감지 + ActivityEvent 발생
  // =============================================================

  Future<Map<String, dynamic>> checkAndEmitRankingChange(String userId) async {
    // 로컬에 캐시된 이전 랭크 조회
    final lastRankResult = await _client
        .from('user_ranking_cache')
        .select('weekly_rank, monthly_rank')
        .eq('user_id', userId)
        .maybeSingle();

    final int oldWeeklyRank = lastRankResult?['weekly_rank'] as int? ?? 999;
    final int oldMonthlyRank = lastRankResult?['monthly_rank'] as int? ?? 999;

    // 현재 랭킹 조회
    final myWeeklyRank = await _findMyRank(
      await _getWeeklyRankingRaw(),
      userId,
    );
    final myMonthlyRank = await _findMyRank(
      await _getMonthlyRankingRaw(),
      userId,
    );

    final engine = ActivityEngine(_client);

    // 주간 랭킹 변동
    if (myWeeklyRank < oldWeeklyRank && myWeeklyRank <= 3) {
      try {
        await engine.emitRankingChanged(
          userId: userId,
          oldRank: oldWeeklyRank,
          newRank: myWeeklyRank,
          scope: '주간',
        );
      } catch (e) {
        print('RankingService weekly event: $e');
      }
    }

    // 월간 랭킹 변동
    if (myMonthlyRank < oldMonthlyRank && myMonthlyRank <= 3) {
      try {
        await engine.emitRankingChanged(
          userId: userId,
          oldRank: oldMonthlyRank,
          newRank: myMonthlyRank,
          scope: '월간',
        );
      } catch (e) {
        print('RankingService monthly event: $e');
      }
    }

    // 캐시 업데이트
    await _client.from('user_ranking_cache').upsert({
      'user_id': userId,
      'weekly_rank': myWeeklyRank,
      'monthly_rank': myMonthlyRank,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    return {
      'oldWeeklyRank': oldWeeklyRank,
      'newWeeklyRank': myWeeklyRank,
      'oldMonthlyRank': oldMonthlyRank,
      'newMonthlyRank': myMonthlyRank,
    };
  }

  Future<int> _findMyRank(List<Map<String, dynamic>> ranking, String userId) async {
    for (int i = 0; i < ranking.length; i++) {
      if (ranking[i]['user_id'] == userId) return i + 1;
    }
    return 999;
  }

  // =============================================================
  // 주간 랭킹
  // =============================================================

  Future<List<RankingResult>> getWeeklyRanking({int limit = 100}) async {
    return _toResults(await _getWeeklyRankingRaw(limit: limit));
  }

  Future<List<Map<String, dynamic>>> _getWeeklyRankingRaw({int limit = 100}) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStr = '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
    final sundayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _getRawRanking(startDate: mondayStr, endDate: sundayStr, limit: limit);
  }

  // =============================================================
  // 월간 랭킹
  // =============================================================

  Future<List<RankingResult>> getMonthlyRanking({int limit = 100}) async {
    return _toResults(await _getMonthlyRankingRaw(limit: limit));
  }

  Future<List<Map<String, dynamic>>> _getMonthlyRankingRaw({int limit = 100}) async {
    final now = DateTime.now();
    final firstDay = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final lastDay = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _getRawRanking(startDate: firstDay, endDate: lastDay, limit: limit);
  }

  // =============================================================
  // 전체 랭킹
  // =============================================================

  Future<List<RankingResult>> getAllTimeRanking({int limit = 100}) async {
    return _toResults(await _getRawRanking(limit: limit));
  }

  // =============================================================
  // Family 랭킹
  // =============================================================

  Future<List<RankingResult>> getFamilyRanking(String userId, {int limit = 20}) async {
    final familyResult = await _client
        .from('family_members')
        .select('user_id')
        .eq('family_id', await _getUserFamilyId(userId));

    if (familyResult == null || (familyResult as List).isEmpty) {
      final raw = await _getRawRanking(limit: limit);
      return _toResults(raw.where((r) => r['user_id'] == userId).toList());
    }

    final familyIds = (familyResult).map((e) => (e['user_id'] as String)).toList();
    final raw = await _getRawRanking(userIds: familyIds, limit: limit);
    return _toResults(raw);
  }

  // =============================================================
  // Internal
  // =============================================================

  Future<String?> _getUserFamilyId(String userId) async {
    final result = await _client
        .from('family_members')
        .select('family_id')
        .eq('user_id', userId)
        .maybeSingle();
    return result?['family_id']?.toString();
  }

  Future<List<Map<String, dynamic>>> _getRawRanking({
    String? startDate,
    String? endDate,
    int limit = 100,
    List<String>? userIds,
  }) async {
    final query = _client.from('health_daily').select(
      'user_id, steps.sum(), distance_km.sum(), profiles!inner(name)',
    );

    if (startDate != null) query.gte('date', startDate);
    if (endDate != null) query.lte('date', endDate);
    if (userIds != null && userIds.isNotEmpty) query.inFilter('user_id', userIds);

    final raw = await query.order('sum', ascending: false).limit(limit);
    return (raw as List).cast<Map<String, dynamic>>();
  }

  List<RankingResult> _toResults(List<Map<String, dynamic>> raw) {
    int rank = 1;
    return raw
        .map((row) => RankingResult(
              userId: row['user_id'] as String,
              userName: row['profiles']?['name'] as String? ?? '알 수 없음',
              totalSteps: (row['sum'] ?? 0) as int,
              totalDistance: (row['distance_km.sum()'] ?? 0).toDouble(),
              rank: rank++,
            ))
        .toList();
  }
}
