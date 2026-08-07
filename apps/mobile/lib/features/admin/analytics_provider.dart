/// ===============================================================
/// HealthON — Analytics Provider
/// ===============================================================

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_repository.dart';
import 'admin_provider.dart';

final analyticsRepoProvider = Provider<AnalyticsRepository>((ref) => AnalyticsRepository(ref.watch(adminSupabaseProvider)));

final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) => ref.watch(analyticsRepoProvider).getSummary());

final analyticsTrendProvider = FutureProvider<List<TrendPoint>>((ref) => ref.watch(analyticsRepoProvider).getTrendData());

final analyticsCategoryDistProvider = FutureProvider<List<CategoryDist>>((ref) => ref.watch(analyticsRepoProvider).getCategoryDistribution());

final analyticsDailyStatsProvider = FutureProvider<List<DailyStat>>((ref) => ref.watch(analyticsRepoProvider).getDailyStats());
