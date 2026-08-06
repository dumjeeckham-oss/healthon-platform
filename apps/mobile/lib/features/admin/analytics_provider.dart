/// ===============================================================
/// HealthON — Analytics Provider
/// ===============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'analytics_repository.dart';
import 'admin_models.dart';

final analyticsRepoProvider = Provider<AnalyticsRepository>((ref) => AnalyticsRepository(ref.watch(adminSupabaseProvider)));

final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) => ref.watch(analyticsRepoProvider).getSummary());

final analyticsTrendProvider = FutureProvider<List<TrendPoint>>((ref) => ref.watch(analyticsRepoProvider).getTrendData());

final analyticsCategoryDistProvider = FutureProvider<List<CategoryDist>>((ref) => ref.watch(analyticsRepoProvider).getCategoryDistribution());

final analyticsDailyStatsProvider = FutureProvider<List<DailyStat>>((ref) => ref.watch(analyticsRepoProvider).getDailyStats());
