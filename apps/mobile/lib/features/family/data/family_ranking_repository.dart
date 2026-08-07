import 'package:supabase_flutter/supabase_flutter.dart';

/// ===============================================================
/// Family Ranking User
/// ===============================================================

class FamilyRankingUser {
  final String id;
  final String name;
  final String? photoUrl;
  final int totalSteps;
  final double totalDistance;
  final int rank;

  const FamilyRankingUser({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.totalSteps,
    required this.totalDistance,
    required this.rank,
  });
}

/// ===============================================================
/// Family Ranking Repository — health_daily 기반
/// ===============================================================

class FamilyRankingRepository {
  FamilyRankingRepository();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<FamilyRankingUser>> fetchRanking() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return [];

    // 내 family_id 조회
    final myProfile = await _supabase
        .from('users')
        .select()
        .eq('id', authUser.id)
        .single();

    final familyId = myProfile['family_id'];
    if (familyId == null) return [];

    // 가족 구성원
    final familyMembers = await _supabase
        .from('users')
        .select()
        .eq('family_id', familyId);

    final List<FamilyRankingUser> ranking = [];

    for (final member in familyMembers) {
      // health_daily.totalSteps == 전체 걸음수
      final result = await _supabase
          .from('health_daily')
          .select('steps.sum(), distance_km.sum()')
          .eq('user_id', member['id']);

      int totalSteps = 0;
      double totalDistance = 0.0;

      if (result.isNotEmpty) {
        final row = result.first;
        totalSteps = (row['sum'] ?? 0) as int;
        totalDistance = (row['distance_km.sum()'] ?? 0).toDouble();
      }

      ranking.add(FamilyRankingUser(
        id: member['id'],
        name: member['nickname'] ?? member['name'] ?? '조합원',
        photoUrl: member['photo_url'],
        totalSteps: totalSteps,
        totalDistance: totalDistance,
        rank: 0,
      ));
    }

    // 내림차순 정렬
    ranking.sort((a, b) => b.totalSteps.compareTo(a.totalSteps));

    // 순위 부여
    final List<FamilyRankingUser> result = [];
    for (int i = 0; i < ranking.length; i++) {
      result.add(FamilyRankingUser(
        id: ranking[i].id,
        name: ranking[i].name,
        photoUrl: ranking[i].photoUrl,
        totalSteps: ranking[i].totalSteps,
        totalDistance: ranking[i].totalDistance,
        rank: i + 1,
      ));
    }

    return result;
  }
}
