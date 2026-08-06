/// ===============================================================
/// HealthON — Ranking Service (Supabase SQL 기반)
///
/// health_daily.steps 합계 → 주간/월간/전체 랭킹
/// ===============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

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
  // 주간 랭킹 (이번주 월요일~일요일)
  // =============================================================

  Future<List<RankingResult>> getWeeklyRanking({int limit = 100}) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStr = '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
    final sundayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return _getRanking(
      startDate: mondayStr,
      endDate: sundayStr,
      limit: limit,
    );
  }

  // =============================================================
  // 월간 랭킹
  // =============================================================

  Future<List<RankingResult>> getMonthlyRanking({int limit = 100}) async {
    final now = DateTime.now();
    final firstDay = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final lastDay = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return _getRanking(
      startDate: firstDay,
      endDate: lastDay,
      limit: limit,
    );
  }

  // =============================================================
  // 전체 랭킹
  // =============================================================

  Future<List<RankingResult>> getAllTimeRanking({int limit = 100}) async {
    return _getRanking(limit: limit);
  }

  // =============================================================
  // Family 랭킹
  // =============================================================

  Future<List<RankingResult>> getFamilyRanking(
    String userId, {
    int limit = 20,
  }) async {
    // 가족 그룹 멤버 조회
    final familyResult = await _client
        .from('family_members')
        .select('user_id')
        .eq('family_id',
            await _getUserFamilyId(userId));

    if (familyResult == null || (familyResult as List).isEmpty) {
      return [await _getUserRanking(userId)];
    }

    final familyIds =
        (familyResult).map((e) => (e['user_id'] as String)).toList();

    return _getRanking(userIds: familyIds, limit: limit);
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

  Future<List<RankingResult>> _getRanking({
    String? startDate,
    String? endDate,
    int limit = 100,
    List<String>? userIds,
  }) async {
    // health_daily.steps 집계 + profiles.name JOIN + 순위
    final query = _client.from('health_daily').select(
      'user_id, steps.sum(), distance_km.sum(), profiles!inner(name)',
    );

    if (startDate != null) {
      query.gte('date', startDate);
    }
    if (endDate != null) {
      query.lte('date', endDate);
    }
    if (userIds != null && userIds.isNotEmpty) {
      query.inFilter('user_id', userIds);
    }

    final raw = await query.order('sum', ascending: false).limit(limit);

    final List<RankingResult> results = [];
    int rank = 1;

    for (final row in raw as List) {
      results.add(RankingResult(
        userId: row['user_id'] as String,
        userName: row['profiles']?['name'] as String? ?? '알 수 없음',
        totalSteps: (row['sum'] ?? 0) as int,
        totalDistance: (row['distance_km.sum()'] ?? 0).toDouble(),
        rank: rank,
      ));
      rank++;
    }

    return results;
  }

  Future<RankingResult> _getUserRanking(String userId) async {
    final result = await _client
        .from('health_daily')
        .select('steps.sum(), distance_km.sum()')
        .eq('user_id', userId);

    final sum = result is List && result.isNotEmpty ? result.first : null;

    return RankingResult(
      userId: userId,
      userName: '나',
      totalSteps: sum?['sum'] as int? ?? 0,
      totalDistance: (sum?['distance_km.sum()'] ?? 0).toDouble(),
      rank: 1,
    );
  }
}
