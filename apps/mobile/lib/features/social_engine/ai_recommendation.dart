import 'package:supabase_flutter/supabase_flutter.dart';

/// ===============================================================
/// HealthON — AI Recommendation Engine (Rule-based MVP)
///
/// 사용자 활동 패턴 분석 → 추천 챌린지 / 미션 / 친구
/// 추후 Gemini/OpenAI API 연동 가능하도록 interface 설계
/// ===============================================================

class RecommendedChallenge {
  final String name;
  final String description;
  final int targetSteps;
  final String reason;

  const RecommendedChallenge({
    required this.name,
    required this.description,
    required this.targetSteps,
    required this.reason,
  });
}

class RecommendedFriend {
  final String userId;
  final String userName;
  final int weeklySteps;
  final String reason;

  const RecommendedFriend({
    required this.userId,
    required this.userName,
    required this.weeklySteps,
    required this.reason,
  });
}

class RecommendationResult {
  final List<RecommendedChallenge> challenges;
  final String dailyMessage;
  final List<RecommendedFriend> friends;

  const RecommendationResult({
    required this.challenges,
    required this.dailyMessage,
    required this.friends,
  });
}

class AiRecommendationEngine {
  AiRecommendationEngine(this._client);

  final SupabaseClient _client;

  /// 종합 추천 생성
  Future<RecommendationResult> generateRecommendations(String userId) async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final weekAgo = today.subtract(const Duration(days: 7));
    final weekAgoStr = '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';

    // 1. 오늘 걸음 수 조회
    final todayHealth = await _client
        .from('health_daily')
        .select('steps, distance_km, exercise_minutes')
        .eq('user_id', userId)
        .eq('date', todayStr)
        .maybeSingle();

    final todaySteps = todayHealth?['steps'] as int? ?? 0;

    // 2. 주간 평균 걸음
    final weeklyResult = await _client
        .from('health_daily')
        .select('steps')
        .eq('user_id', userId)
        .gte('date', weekAgoStr)
        .lte('date', todayStr);

    int weeklyTotal = 0;
    int weeklyDays = 0;
    for (final row in weeklyResult as List) {
      weeklyTotal += (row['steps'] ?? 0) as int;
      weeklyDays++;
    }

    final weeklyAvg = weeklyDays > 0 ? (weeklyTotal / weeklyDays).round() : 0;

    // 3. Forest 레벨
    final forest = await _client
        .from('forest_progress')
        .select('tree_level')
        .eq('user_id', userId)
        .maybeSingle();
    final forestLevel = forest?['tree_level'] as int? ?? 1;

    // 4. Challenge 진행률
    final challenge = await _client
        .from('challenge_progress')
        .select('progress, completed, total_distance')
        .eq('user_id', userId)
        .maybeSingle();
    final challengeProgress = challenge?['progress'] as double? ?? 0;
    final challengeKm = challenge?['total_distance'] as double? ?? 0;

    // 5. 추천 생성
    return RecommendationResult(
      challenges: _recommendChallenges(weeklyAvg, forestLevel, challengeProgress, challengeKm),
      dailyMessage: _generateDailyMessage(todaySteps, weeklyAvg, forestLevel),
      friends: await _recommendFriends(userId, weeklyTotal),
    );
  }

  // =============================================================
  // Challenge 추천
  // =============================================================

  List<RecommendedChallenge> _recommendChallenges(
    int weeklyAvg,
    int forestLevel,
    double challengeProgress,
    double challengeKm,
  ) {
    final challenges = <RecommendedChallenge>[];

    // 100K Challenge 진행 중이면 현재 상태 알림
    if (challengeProgress < 1.0) {
      final remaining = 100 - challengeKm;
      final daysLeft = weeklyAvg > 0 ? (remaining / (weeklyAvg * 0.7 / 1000)).ceil() : 30;
      challenges.add(RecommendedChallenge(
        name: '100K Challenge',
        description: '${remaining.toStringAsFixed(1)}km 남았어요!',
        targetSteps: (remaining * 1000 / 0.7).round(),
        reason: '하루 ${weeklyAvg}보 페이스면 약 $daysLeft일 후 완료 예상',
      ));
    }

    // Forest 성장 챌린지
    if (forestLevel < 8) {
      final toNext = _forestNextThreshold(forestLevel);
      final needed = toNext > 0 ? '다음 레벨까지 ${toNext}보' : '';
      challenges.add(RecommendedChallenge(
        name: 'Forest 성장 챌린지',
        description: 'Lv.$forestLevel → Lv.${forestLevel + 1}',
        targetSteps: 5000,
        reason: needed,
      ));
    }

    // 일일 걸음 챌린지
    if (weeklyAvg < 10000) {
      challenges.add(RecommendedChallenge(
        name: '10,000보 챌린지',
        description: '하루 10,000보 달성하기',
        targetSteps: 10000,
        reason: '현재 주간 평균 ${weeklyAvg}보 — 조금만 더!',
      ));
    }

    // 주간 70,000보 챌린지
    if (weeklyAvg >= 8000) {
      challenges.add(RecommendedChallenge(
        name: '주간 70K 챌린지',
        description: '일주일 70,000보 걷기',
        targetSteps: 70000,
        reason: '주간 평균 ${weeklyAvg}보 — 충분히 가능합니다!',
      ));
    }

    return challenges.take(3).toList();
  }

  // =============================================================
  // 친구 추천
  // =============================================================

  Future<List<RecommendedFriend>> _recommendFriends(String userId, int myWeeklySteps) async {
    // 팔로우하지 않은 상위 걸음 사용자 추천
    final following = await _client
        .from('social_graph')
        .select('to_user_id')
        .eq('from_user_id', userId);

    final followingIds = (following as List)
        .map((e) => (e['to_user_id'] as String))
        .toSet();
    followingIds.add(userId);

    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 7));
    final weekAgoStr = '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      final candidates = await _client
          .from('health_daily')
          .select('user_id, steps.sum(), profiles!inner(name)')
          .gte('date', weekAgoStr)
          .lte('date', todayStr)
          .order('sum', ascending: false)
          .limit(20);

      final friends = <RecommendedFriend>[];
      for (final row in candidates as List) {
        final candidateId = row['user_id'] as String;
        if (followingIds.contains(candidateId)) continue;

        final weeklySteps = (row['sum'] ?? 0) as int;
        final name = row['profiles']?['name'] as String? ?? '사용자';

        String reason;
        if (weeklySteps > myWeeklySteps) {
          reason = '주간 $weeklySteps보 — 함께 걸으면 동기부여!';
        } else {
          reason = '비슷한 활동량의 사용자입니다';
        }

        friends.add(RecommendedFriend(
          userId: candidateId,
          userName: name,
          weeklySteps: weeklySteps,
          reason: reason,
        ));

        if (friends.length >= 5) break;
      }

      return friends;
    } catch (_) {
      return [];
    }
  }

  // =============================================================
  // 오늘의 한마디
  // =============================================================

  String _generateDailyMessage(int todaySteps, int weeklyAvg, int forestLevel) {
    if (todaySteps >= 10000) {
      return '🎉 오늘 10,000보 달성! 대단해요! Forest도 함께 자라고 있어요 🌳';
    }
    if (todaySteps >= 5000) {
      final remaining = 10000 - todaySteps;
      return '🔥 잘하고 있어요! 앞으로 ${remaining}보만 더 걸으면 목표 달성!';
    }
    if (weeklyAvg >= 8000) {
      return '💪 꾸준히 걷고 계시네요. 오늘도 목표를 향해!';
    }

    final treeEmoji = switch (forestLevel) {
      1 => '🌱',
      2 => '🌿',
      3 => '🪴',
      4 => '🌳',
      5 => '🌲',
      6 => '🏞️',
      7 => '🌴',
      _ => '🏝️',
    };

    return '🚶‍♂️ 오늘의 첫 걸음을 시작해볼까요? Forest Lv.$forestLevel $treeEmoji';
  }

  int _forestNextThreshold(int currentLevel) {
    const thresholds = [0, 5000, 15000, 30000, 50000, 80000, 120000, 200000];
    if (currentLevel >= thresholds.length) return 0;
    return thresholds[currentLevel];
  }
}
