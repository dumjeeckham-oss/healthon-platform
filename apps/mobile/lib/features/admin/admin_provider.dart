import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_models.dart';
import 'supabase_admin_repository.dart';

// ===============================================================
// Supabase Client
// ===============================================================

final adminSupabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ===============================================================
// Repository
// ===============================================================

final adminRepositoryProvider = Provider<SupabaseAdminRepository>(
  (ref) => SupabaseAdminRepository(ref.watch(adminSupabaseProvider)),
);

// ===============================================================
// 관리자 체크
// ===============================================================

final isAdminProvider = Provider<bool>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;
  // 실제로는 profiles 테이블의 is_admin을 확인해야 함
  return user.userMetadata?['is_admin'] == true;
});

// ===============================================================
// Dashboard Stats
// ===============================================================

final adminDashboardStatsProvider = FutureProvider<AdminDashboardStats>((ref) async {
  return ref.watch(adminRepositoryProvider).getDashboardStats();
});

final adminWeeklyStepsChartProvider = FutureProvider<AdminChartData>((ref) async {
  return ref.watch(adminRepositoryProvider).getWeeklyStepsChart();
});

final adminDailyUsersChartProvider = FutureProvider<AdminChartData>((ref) async {
  return ref.watch(adminRepositoryProvider).getDailyUsersChart();
});

// ===============================================================
// Members
// ===============================================================

final adminMembersProvider = FutureProvider<List<AdminMember>>((ref) async {
  return ref.watch(adminRepositoryProvider).getMembers();
});

// ===============================================================
// Notices
// ===============================================================

final adminNoticesProvider = FutureProvider<List<AdminNotice>>((ref) async {
  return ref.watch(adminRepositoryProvider).getNotices();
});

// ===============================================================
// Reports
// ===============================================================

final adminReportsProvider = FutureProvider<List<AdminReport>>((ref) async {
  return ref.watch(adminRepositoryProvider).getReports();
});

// ===============================================================
// Challenges
// ===============================================================

final adminChallengesProvider = FutureProvider<List<AdminChallengeDefinition>>((ref) async {
  return ref.watch(adminRepositoryProvider).getChallenges();
});

// ===============================================================
// Missions
// ===============================================================

final adminMissionsProvider = FutureProvider<List<AdminMissionDefinition>>((ref) async {
  return ref.watch(adminRepositoryProvider).getMissions();
});

// ===============================================================
// Forest Seasons
// ===============================================================

final adminForestSeasonsProvider = FutureProvider<List<AdminForestSeason>>((ref) async {
  return ref.watch(adminRepositoryProvider).getForestSeasons();
});

// ===============================================================
// Banners
// ===============================================================

final adminBannersProvider = FutureProvider<List<AdminBanner>>((ref) async {
  return ref.watch(adminRepositoryProvider).getBanners();
});

// ===============================================================
// Corporate News (법인소식)
// ===============================================================

final adminCorporateNewsProvider = FutureProvider<List<CorporateNews>>((ref) async {
  return ref.watch(adminRepositoryProvider).getCorporateNews();
});

// ===============================================================
// Analytics
// ===============================================================

final adminAnalyticsOverviewProvider = FutureProvider<AnalyticsOverview>((ref) async {
  return ref.watch(adminRepositoryProvider).getAnalyticsOverview();
});

final adminDAUChartProvider = FutureProvider.family<AdminChartData, int>((ref, days) async {
  return ref.watch(adminRepositoryProvider).getDAUChart(days);
});

final adminRetentionChartProvider = FutureProvider<AdminChartData>((ref) async {
  return ref.watch(adminRepositoryProvider).getRetentionChart();
});

final adminPostsCommentsChartProvider = FutureProvider.family<AdminChartData, int>((ref, days) async {
  return ref.watch(adminRepositoryProvider).getPostsCommentsChart(days);
});
