import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/forest_summary.dart';

class ForestRepository {
  ForestRepository();

  final SupabaseClient _client = Supabase.instance.client;

  /// ===========================================================
  /// Forest 정보 조회
  /// ===========================================================
  Future<ForestSummary> getSummary(String userId) async {
    final result = await _client
        .from('forest_progress')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (result == null) {
      return ForestSummary.empty();
    }

    return ForestSummary.fromMap(result);
  }

  /// ===========================================================
  /// 누적 거리 저장 + 레벨 자동 계산
  /// ===========================================================
  Future<void> updateDistance({
    required String userId,
    required double totalKm,
  }) async {
    final summary = _calculateLevel(totalKm);

    await _client.from('forest_progress').upsert({
      'user_id': userId,
      'total_km': totalKm,
      'tree_level': summary.treeLevel,
      'tree_exp': summary.treeExp,
      'next_level_exp': summary.nextLevelExp,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// ===========================================================
  /// 레벨 계산 엔진
  /// ===========================================================
  ForestSummary _calculateLevel(double totalKm) {
    const levels = <double>[
      0,
      100,
      250,
      450,
      700,
      1000,
      1400,
      1900,
      2500,
      3200,
    ];

    int level = 1;

    for (int i = 0; i < levels.length; i++) {
      if (totalKm >= levels[i]) {
        level = i + 1;
      }
    }

    double currentExp;
    double nextExp;

    if (level >= levels.length) {
      final base = levels.last;

      currentExp = totalKm - base;
      nextExp = 500;
    } else {
      currentExp = totalKm - levels[level - 1];
      nextExp = levels[level] - levels[level - 1];
    }

    return ForestSummary(
      totalKm: totalKm,
      treeLevel: level,
      treeExp: currentExp,
      nextLevelExp: nextExp,
      treeName: _treeName(level),
    );
  }

  /// ===========================================================
  /// 나무 이름
  /// ===========================================================
  String _treeName(int level) {
    switch (level) {
      case 1:
        return "🌱 새싹";

      case 2:
        return "🌿 풀";

      case 3:
        return "🌳 묘목";

      case 4:
        return "🌲 어린나무";

      case 5:
        return "🌴 큰나무";

      case 6:
        return "🌳 울창한 나무";

      case 7:
        return "🌲 거목";

      case 8:
        return "🌳 신목";

      case 9:
        return "🌲 숲의 수호목";

      default:
        return "🌳 생명의 나무";
    }
  }
}
