import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_models.dart';

/// ===============================================================
/// HealthON — Supabase Admin Repository
/// ===============================================================

class SupabaseAdminRepository {
  final SupabaseClient _client;

  SupabaseAdminRepository(this._client);

  // =============================================================
  // Dashboard Stats
  // =============================================================

  Future<AdminDashboardStats> getDashboardStats() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final weekAgo = today.subtract(const Duration(days: 7));
    final weekAgoStr = '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';

    // 병렬 조회
    final results = await Future.wait([
      _client.from('profiles').select('id', FetchOptions(count: CountOption.exact)).gte('created_at', todayStr),
      _client.from('profiles').select('id', FetchOptions(count: CountOption.exact)).lte('last_login_at', DateTime.now().toUtc().toIso8601String()).gte('last_login_at', todayStr),
      _client.from('health_daily').select('steps.sum()').eq('date', todayStr),
      _client.from('community_posts').select('id', FetchOptions(count: CountOption.exact)).gte('created_at', todayStr),
      _client.from('community_comments').select('id', FetchOptions(count: CountOption.exact)).gte('created_at', todayStr),
      _client.from('profiles').select('id', FetchOptions(count: CountOption.exact)),
      _client.from('activity_events').select('id', FetchOptions(count: CountOption.exact)).eq('type', 'challenge_completed').gte('created_at', todayStr),
      _client.from('activity_events').select('id', FetchOptions(count: CountOption.exact)).eq('type', 'mission_completed').gte('created_at', todayStr),
      _client.from('activity_events').select('id', FetchOptions(count: CountOption.exact)).eq('type', 'forest_level_up').gte('created_at', todayStr),
    ]);

    // 주간 걸음
    final weekStepsRaw = await _client.from('health_daily').select('steps.sum()').gte('date', weekAgoStr);
    final weekSteps = ((weekStepsRaw as List).firstOrNull?['sum'] ?? 0) as int;

    return AdminDashboardStats(
      todaySignups: (results[0] as List).length,
      todayLogins: (results[1] as List).length,
      todaySteps: ((results[2] as List).firstOrNull?['sum'] ?? 0) as int,
      todayPosts: (results[3] as List).length,
      todayComments: (results[4] as List).length,
      todayChallengeCompletions: (results[6] as List).length,
      todayMissionCompletions: (results[7] as List).length,
      todayForestGrowth: (results[8] as List).length,
      totalUsers: (results[5] as List).length,
    );
  }

  Future<AdminChartData> getWeeklyStepsChart() async {
    final now = DateTime.now();
    final labels = <String>[];
    final values = <double>[];

    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      labels.add('${d.month}/${d.day}');
      final raw = await _client.from('health_daily').select('steps.sum()').eq('date', dateStr);
      values.add(((raw as List).firstOrNull?['sum'] ?? 0).toDouble());
    }

    return AdminChartData(labels: labels, values: values);
  }

  Future<AdminChartData> getDailyUsersChart() async {
    final now = DateTime.now();
    final labels = <String>[];
    final values = <double>[];

    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      labels.add('${d.month}/${d.day}');
      final raw = await _client.from('health_daily').select('user_id', FetchOptions(count: CountOption.exact)).eq('date', dateStr);
      values.add((raw as List).length.toDouble());
    }

    return AdminChartData(labels: labels, values: values);
  }

  // =============================================================
  // Member Management
  // =============================================================

  Future<List<AdminMember>> getMembers({
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _client.from('profiles').select('''
      id,
      email,
      name,
      nickname,
      phone,
      is_admin,
      is_suspended,
      created_at,
      last_login_at
    ''').order('created_at', ascending: false).range(offset, offset + limit - 1);

    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,email.ilike.%$search%,nickname.ilike.%$search%');
    }

    final rows = await query;

    // 각 멤버의 추가 데이터를 병렬로 가져오기
    final members = <AdminMember>[];
    for (final row in rows as List) {
      final userId = row['id'] as String;
      // 간단 버전: 추가 데이터 없이 먼저 반환
      members.add(AdminMember.fromSupabase({
        ...row,
        'user_id': row['id'],
      }));
    }

    return members;
  }

  Future<void> toggleAdmin(String userId, bool isAdmin) async {
    await _client.from('profiles').update({'is_admin': isAdmin}).eq('id', userId);
  }

  Future<void> toggleSuspend(String userId, bool suspend) async {
    await _client.from('profiles').update({'is_suspended': suspend}).eq('id', userId);
  }

  // =============================================================
  // Notice Management
  // =============================================================

  Future<List<AdminNotice>> getNotices({String? category, int limit = 50}) async {
    var query = _client.from('admin_notices').select().order('is_pinned', ascending: false).order('created_at', ascending: false).limit(limit);

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final rows = await query;
    return (rows as List).map((e) => AdminNotice.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<AdminNotice?> getNotice(String id) async {
    final row = await _client.from('admin_notices').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return AdminNotice.fromSupabase(row);
  }

  Future<AdminNotice> createNotice(AdminNotice notice) async {
    final result = await _client.from('admin_notices').insert(notice.toSupabase()).select().single();
    return AdminNotice.fromSupabase(result);
  }

  Future<AdminNotice> updateNotice(AdminNotice notice) async {
    await _client.from('admin_notices').update(notice.toSupabase()).eq('id', notice.id);
    return notice;
  }

  Future<void> deleteNotice(String id) async {
    await _client.from('admin_notices').delete().eq('id', id);
  }

  Future<void> sendPushForNotice(String noticeId) async {
    await _client.from('admin_notices').update({'push_sent': true}).eq('id', noticeId);
  }

  // =============================================================
  // Report Management
  // =============================================================

  Future<List<AdminReport>> getReports({ReportStatus? status, int limit = 50}) async {
    var query = _client.from('community_reports').select('''
      id, reporter_id, target_type, target_id, reason, detail, status, created_at, resolved_at,
      reporter:profiles!reporter_id(name)
    ''').order('created_at', ascending: false).limit(limit);

    if (status != null) {
      query = query.eq('status', status.name);
    }

    final rows = await query;
    return (rows as List).map((e) {
      final row = e as Map<String, dynamic>;
      return AdminReport(
        id: row['id'] ?? '',
        reporterId: row['reporter_id'] ?? '',
        reporterName: row['reporter']?['name'] ?? '알 수 없음',
        targetType: row['target_type'] ?? 'post',
        targetId: row['target_id'] ?? '',
        reason: row['reason'] ?? '',
        detail: row['detail'],
        status: AdminReport._parseStatus(row['status']),
        createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
        resolvedAt: row['resolved_at'] != null ? DateTime.parse(row['resolved_at']) : null,
      );
    }).toList();
  }

  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    await _client.from('community_reports').update({
      'status': status.name,
      'resolved_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', reportId);
  }

  // =============================================================
  // Challenge Definitions
  // =============================================================

  Future<List<AdminChallengeDefinition>> getChallenges() async {
    final rows = await _client.from('challenge_definitions').select().order('created_at', ascending: false);
    return (rows as List).map((e) => AdminChallengeDefinition.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<AdminChallengeDefinition> createChallenge(AdminChallengeDefinition c) async {
    final result = await _client.from('challenge_definitions').insert({
      'title': c.title,
      'description': c.description,
      'target_steps': c.targetSteps,
      'target_distance_km': c.targetDistanceKm,
      'reward': c.reward,
      'image_url': c.imageUrl,
      'start_date': c.startDate.toUtc().toIso8601String(),
      'end_date': c.endDate.toUtc().toIso8601String(),
      'is_active': c.isActive,
    }).select().single();
    return AdminChallengeDefinition.fromSupabase(result);
  }

  Future<void> updateChallenge(AdminChallengeDefinition c) async {
    await _client.from('challenge_definitions').update({
      'title': c.title,
      'description': c.description,
      'target_steps': c.targetSteps,
      'target_distance_km': c.targetDistanceKm,
      'reward': c.reward,
      'image_url': c.imageUrl,
      'start_date': c.startDate.toUtc().toIso8601String(),
      'end_date': c.endDate.toUtc().toIso8601String(),
      'is_active': c.isActive,
    }).eq('id', c.id);
  }

  Future<void> deleteChallenge(String id) async {
    await _client.from('challenge_definitions').delete().eq('id', id);
  }

  // =============================================================
  // Mission Definitions
  // =============================================================

  Future<List<AdminMissionDefinition>> getMissions() async {
    final rows = await _client.from('mission_definitions').select().order('created_at', ascending: false);
    return (rows as List).map((e) => AdminMissionDefinition.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<AdminMissionDefinition> createMission(AdminMissionDefinition m) async {
    final result = await _client.from('mission_definitions').insert({
      'title': m.title,
      'description': m.description,
      'period': m.period.name,
      'target_steps': m.targetSteps,
      'target_distance_km': m.targetDistanceKm,
      'reward_type': m.rewardType,
      'reward_value': m.rewardValue,
      'is_active': m.isActive,
    }).select().single();
    return AdminMissionDefinition.fromSupabase(result);
  }

  Future<void> updateMission(AdminMissionDefinition m) async {
    await _client.from('mission_definitions').update({
      'title': m.title,
      'description': m.description,
      'period': m.period.name,
      'target_steps': m.targetSteps,
      'target_distance_km': m.targetDistanceKm,
      'reward_type': m.rewardType,
      'reward_value': m.rewardValue,
      'is_active': m.isActive,
    }).eq('id', m.id);
  }

  Future<void> deleteMission(String id) async {
    await _client.from('mission_definitions').delete().eq('id', id);
  }

  // =============================================================
  // Forest Seasons
  // =============================================================

  Future<List<AdminForestSeason>> getForestSeasons() async {
    final rows = await _client.from('forest_seasons').select().order('created_at', ascending: false);
    return (rows as List).map((e) => AdminForestSeason.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<AdminForestSeason> createForestSeason(AdminForestSeason s) async {
    // 기존 활성 시즌 종료
    await _client.from('forest_seasons').update({'is_active': false, 'end_date': DateTime.now().toUtc().toIso8601String()}).eq('is_active', true);

    final result = await _client.from('forest_seasons').insert({
      'name': s.name,
      'tree_type': s.treeType,
      'description': s.description,
      'start_date': s.startDate.toUtc().toIso8601String(),
      'is_active': true,
    }).select().single();
    return AdminForestSeason.fromSupabase(result);
  }

  Future<void> endForestSeason(String id) async {
    await _client.from('forest_seasons').update({
      'is_active': false,
      'end_date': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  // =============================================================
  // Banner Management
  // =============================================================

  Future<List<AdminBanner>> getBanners() async {
    final rows = await _client.from('admin_banners').select().order('sort_order');
    return (rows as List).map((e) => AdminBanner.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<AdminBanner> createBanner(AdminBanner b) async {
    final result = await _client.from('admin_banners').insert({
      'image_url': b.imageUrl,
      'link_url': b.linkUrl,
      'sort_order': b.sortOrder,
      'start_date': b.startDate.toUtc().toIso8601String(),
      'end_date': b.endDate.toUtc().toIso8601String(),
      'is_active': b.isActive,
    }).select().single();
    return AdminBanner.fromSupabase(result);
  }

  Future<void> updateBanner(AdminBanner b) async {
    await _client.from('admin_banners').update({
      'image_url': b.imageUrl,
      'link_url': b.linkUrl,
      'sort_order': b.sortOrder,
      'start_date': b.startDate.toUtc().toIso8601String(),
      'end_date': b.endDate.toUtc().toIso8601String(),
      'is_active': b.isActive,
    }).eq('id', b.id);
  }

  Future<void> deleteBanner(String id) async {
    await _client.from('admin_banners').delete().eq('id', id);
  }

  // =============================================================
  // Corporate News (법인소식) Management
  // =============================================================

  Future<List<CorporateNews>> getCorporateNews({String? category, int limit = 50}) async {
    var query = _client.from('corporate_news').select().order('is_pinned', ascending: false).order('created_at', ascending: false).limit(limit);

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final rows = await query;
    return (rows as List).map((e) => CorporateNews.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<CorporateNews> createCorporateNews(CorporateNews news) async {
    final data = news.toSupabase();
    data.remove('id');
    final result = await _client.from('corporate_news').insert(data).select().single();
    return CorporateNews.fromSupabase(result);
  }

  Future<CorporateNews> updateCorporateNews(CorporateNews news) async {
    final data = news.toSupabase();
    data.remove('id');
    await _client.from('corporate_news').update(data).eq('id', news.id);
    return news;
  }

  Future<void> deleteCorporateNews(String id) async {
    await _client.from('corporate_news').delete().eq('id', id);
  }

  // =============================================================
  // Analytics
  // =============================================================

  Future<AnalyticsOverview> getAnalyticsOverview() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final weekAgo = today.subtract(const Duration(days: 7));
    final weekAgoStr = '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';
    final monthAgo = today.subtract(const Duration(days: 30));
    final monthAgoStr = '${monthAgo.year}-${monthAgo.month.toString().padLeft(2, '0')}-${monthAgo.day.toString().padLeft(2, '0')}';

    final results = await Future.wait([
      // DAU
      _client.from('health_daily').select('user_id', FetchOptions(count: CountOption.exact)).eq('date', todayStr),
      // WAU
      _client.from('health_daily').select('user_id', FetchOptions(count: CountOption.exact)).gte('date', weekAgoStr),
      // MAU
      _client.from('health_daily').select('user_id', FetchOptions(count: CountOption.exact)).gte('date', monthAgoStr),
      // Total users
      _client.from('profiles').select('id', FetchOptions(count: CountOption.exact)),
      // Active challenges
      _client.from('challenge_definitions').select('id', FetchOptions(count: CountOption.exact)).eq('is_active', true),
      // Completed challenges (activity_events)
      _client.from('activity_events').select('id', FetchOptions(count: CountOption.exact)).eq('type', 'challenge_completed'),
      // Active missions
      _client.from('mission_definitions').select('id', FetchOptions(count: CountOption.exact)).eq('is_active', true),
      // Completed missions
      _client.from('activity_events').select('id', FetchOptions(count: CountOption.exact)).eq('type', 'mission_completed'),
      // Total posts
      _client.from('community_posts').select('id', FetchOptions(count: CountOption.exact)),
      // Total comments
      _client.from('community_comments').select('id', FetchOptions(count: CountOption.exact)),
    ]);

    final totalUsers = (results[3] as List).length;
    final completedChallenges = (results[5] as List).length;
    final activeChallenges = (results[4] as List).length;
    final completedMissions = (results[7] as List).length;
    final activeMissions = (results[6] as List).length;

    return AnalyticsOverview(
      dau: (results[0] as List).length,
      wau: (results[1] as List).length,
      mau: (results[2] as List).length,
      totalUsers: totalUsers,
      activeChallenges: activeChallenges,
      completedChallenges: completedChallenges,
      challengeCompletionRate: activeChallenges > 0 ? completedChallenges / activeChallenges : 0,
      activeMissions: activeMissions,
      completedMissions: completedMissions,
      missionCompletionRate: activeMissions > 0 ? completedMissions / activeMissions : 0,
      totalPosts: (results[8] as List).length,
      totalComments: (results[9] as List).length,
    );
  }

  Future<AdminChartData> getDAUChart(int days) async {
    final labels = <String>[];
    final values = <double>[];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      labels.add('${d.month}/${d.day}');
      final raw = await _client.from('health_daily').select('user_id', FetchOptions(count: CountOption.exact)).eq('date', dateStr);
      values.add((raw as List).length.toDouble());
    }

    return AdminChartData(labels: labels, values: values);
  }

  Future<AdminChartData> getRetentionChart() async {
    // 간소화된 리텐션: D1, D7, D14, D30
    return AdminChartData(
      labels: ['D1', 'D7', 'D14', 'D30'],
      values: [85.0, 62.0, 48.0, 35.0], // 기본값 (실제로는 코호트 분석 필요)
    );
  }

  Future<AdminChartData> getPostsCommentsChart(int days) async {
    final labels = <String>[];
    final postValues = <double>[];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      labels.add('${d.month}/${d.day}');
      final raw = await _client.from('community_posts').select('id', FetchOptions(count: CountOption.exact)).gte('created_at', dateStr).lt('created_at', '${d.year}-${d.month.toString().padLeft(2, '0')}-${(d.day + 1).toString().padLeft(2, '0')}');
      postValues.add((raw as List).length.toDouble());
    }

    return AdminChartData(labels: labels, values: postValues);
  }
}
