/// ===============================================================
/// HealthON — Analytics Repository
///
/// DAU/MAU, 리텐션, 전환율, 트렌드, 카테고리 분포
/// ===============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

// ===============================================================
// Models
// ===============================================================

class DailyStat {
  final DateTime date;
  final int dau, newUsers;
  final int totalSteps;
  final double totalDistanceKm;
  final int activeChallenges, completedChallenges, completedMissions;
  final int newPosts, newComments, newLikes, cheersSent;

  const DailyStat({
    required this.date, this.dau = 0, this.newUsers = 0, this.totalSteps = 0,
    this.totalDistanceKm = 0, this.activeChallenges = 0, this.completedChallenges = 0,
    this.completedMissions = 0, this.newPosts = 0, this.newComments = 0,
    this.newLikes = 0, this.cheersSent = 0,
  });

  factory DailyStat.fromSupabase(Map<String, dynamic> r) => DailyStat(
    date: DateTime.parse(r['date'] as String), dau: r['dau'] as int? ?? 0,
    newUsers: r['new_users'] as int? ?? 0, totalSteps: r['total_steps'] as int? ?? 0,
    totalDistanceKm: (r['total_distance_km'] as num?)?.toDouble() ?? 0,
    activeChallenges: r['active_challenges'] as int? ?? 0,
    completedChallenges: r['completed_challenges'] as int? ?? 0,
    completedMissions: r['completed_missions'] as int? ?? 0,
    newPosts: r['new_posts'] as int? ?? 0, newComments: r['new_comments'] as int? ?? 0,
    newLikes: r['new_likes'] as int? ?? 0, cheersSent: r['cheers_sent'] as int? ?? 0,
  );
}

class TrendPoint {
  final DateTime date;
  final int dau, newUsers, steps, posts;
  const TrendPoint({required this.date, this.dau = 0, this.newUsers = 0, this.steps = 0, this.posts = 0});
}

class CategoryDist {
  final String category;
  final int count;
  const CategoryDist({required this.category, required this.count});
  String get label => switch (category) {
    'notice' => '공지', 'challenge' => '챌린지', 'walking' => '걷기', 'forest' => 'Forest',
    'health' => '건강', 'photo' => '사진', 'free' => '자유', 'question' => '질문', 'event' => '이벤트',
    _ => category,
  };
}

class RetentionData {
  final List<String> labels; // week-0, week-1, ...
  final List<double> rates;
  const RetentionData({required this.labels, required this.rates});
}

class AnalyticsSummary {
  final int dau, wau, mau;
  final int totalUsers;
  final double dauMauRatio;
  final double avgStepsPerUser;
  final double challengeCompletionRate;
  final double weeklyGrowth;
  final double retentionWeek1;
  final double engagementRate; // posts+comments / dau

  const AnalyticsSummary({
    this.dau = 0, this.wau = 0, this.mau = 0, this.totalUsers = 0,
    this.dauMauRatio = 0, this.avgStepsPerUser = 0,
    this.challengeCompletionRate = 0, this.weeklyGrowth = 0,
    this.retentionWeek1 = 0, this.engagementRate = 0,
  });
}

// ===============================================================
// Repository
// ===============================================================

class AnalyticsRepository {
  final SupabaseClient _client;
  AnalyticsRepository(this._client);

  /// 주간 트렌드 (30일)
  Future<List<TrendPoint>> getTrendData({int days = 30}) async {
    try {
      final rows = await _client.rpc('get_trend_data', params: {'p_days': days});
      return (rows as List).map((e) {
        final r = e as Map<String, dynamic>;
        return TrendPoint(date: DateTime.parse(r['d'] as String), dau: r['dau'] as int? ?? 0, newUsers: r['new_u'] as int? ?? 0, steps: r['steps'] as int? ?? 0, posts: r['posts'] as int? ?? 0);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// 데일리 스탯 직접 조회
  Future<List<DailyStat>> getDailyStats({int days = 14}) async {
    try {
      final rows = await _client.from('daily_stats').select().order('date', ascending: false).limit(days);
      return (rows as List).map((e) => DailyStat.fromSupabase(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// 카테고리 분포
  Future<List<CategoryDist>> getCategoryDistribution() async {
    try {
      final rows = await _client.rpc('get_category_distribution');
      return (rows as List).map((e) {
        final r = e as Map<String, dynamic>;
        return CategoryDist(category: r['category'] ?? '', count: (r['cnt'] ?? 0) as int);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// 분석 요약
  Future<AnalyticsSummary> getSummary() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final monthAgo = now.subtract(const Duration(days: 30));

      final results = await Future.wait<dynamic>([
        _client.from('daily_stats').select('dau').eq('date', now.toIso8601String().substring(0, 10)).maybeSingle(),
        _client.from('daily_stats').select('dau.sum()').gte('date', weekAgo.toIso8601String().substring(0, 10)),
        _client.from('daily_stats').select('dau.sum()').gte('date', monthAgo.toIso8601String().substring(0, 10)),
        _client.from('users').select('id'),
        _client.from('daily_stats').select('total_steps.sum()').gte('date', now.toIso8601String().substring(0, 10)),
      ]);

      final dau = (results[0]?['dau'] ?? 0) as int;
      final wau = ((results[1] as List).firstOrNull?['sum'] ?? 0) as int;
      final mau = ((results[2] as List).firstOrNull?['sum'] ?? 0) as int;
      final totalUsers = (results[3] as List).length;
      final totalSteps = ((results[4] as List).firstOrNull?['sum'] ?? 0) as int;

      return AnalyticsSummary(
        dau: dau, wau: wau, mau: mau, totalUsers: totalUsers,
        dauMauRatio: mau > 0 ? dau / mau : 0,
        avgStepsPerUser: dau > 0 ? totalSteps / dau : 0,
      );
    } catch (_) {
      return const AnalyticsSummary();
    }
  }

  /// 일별 통계 갱신 (Edge Function에서 호출, 또는 수동 트리거)
  Future<void> refreshDailyStats({DateTime? date}) async {
    await _client.rpc('refresh_daily_stats', params: {'p_date': (date ?? DateTime.now()).toIso8601String().substring(0, 10)});
  }
}
