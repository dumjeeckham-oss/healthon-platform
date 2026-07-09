import 'package:supabase_flutter/supabase_flutter.dart';

/// ===============================================================
///
/// Family Ranking Model
///
/// ===============================================================

class FamilyRankingUser {
  final String id;

  final String name;

  final String? photoUrl;

  final int totalSteps;

  final int rank;

  const FamilyRankingUser({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.totalSteps,
    required this.rank,
  });
}

/// ===============================================================
///
/// Family Ranking Repository
///
/// users
/// step_daily
///
/// ===============================================================

class FamilyRankingRepository {
  FamilyRankingRepository();

  final _supabase = Supabase.instance.client;

  Future<List<FamilyRankingUser>> fetchRanking() async {
    final authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      return [];
    }

    //------------------------------------------------------------
    // 내 정보
    //------------------------------------------------------------

    final myProfile = await _supabase
        .from('users')
        .select()
        .eq('id', authUser.id)
        .single();

    final familyId = myProfile['family_id'];

    if (familyId == null) {
      return [];
    }

    //------------------------------------------------------------
    // 가족 조회
    //------------------------------------------------------------

    final familyMembers = await _supabase
        .from('users')
        .select()
        .eq('family_id', familyId);

    final List<FamilyRankingUser> ranking = [];

    //------------------------------------------------------------
    // 각 가족 누적걸음 계산
    //------------------------------------------------------------

    for (final member in familyMembers) {
      final rows = await _supabase
          .from('step_daily')
          .select('steps')
          .eq('user_id', member['id']);

      int total = 0;

      for (final row in rows) {
        total += (row['steps'] ?? 0) as int;
      }

      ranking.add(
        FamilyRankingUser(
          id: member['id'],
          name: member['nickname'] ??
              member['name'] ??
              '조합원',
          photoUrl: member['photo_url'],
          totalSteps: total,
          rank: 0,
        ),
      );
    }

    //------------------------------------------------------------
    // 걸음수 내림차순
    //------------------------------------------------------------

    ranking.sort(
      (a, b) => b.totalSteps.compareTo(a.totalSteps),
    );

    //------------------------------------------------------------
    // 순위 부여
    //------------------------------------------------------------

    final List<FamilyRankingUser> result = [];

    for (int i = 0; i < ranking.length; i++) {
      final user = ranking[i];

      result.add(
        FamilyRankingUser(
          id: user.id,
          name: user.name,
          photoUrl: user.photoUrl,
          totalSteps: user.totalSteps,
          rank: i + 1,
        ),
      );
    }

    return result;
  }
}
