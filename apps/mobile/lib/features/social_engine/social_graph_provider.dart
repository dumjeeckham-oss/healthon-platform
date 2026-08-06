import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'activity_models.dart';

// ===============================================================
// Supabase Client
// ===============================================================

final socialGraphSupabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ===============================================================
// User Id
// ===============================================================

final socialGraphUserIdProvider = Provider<String?>(
  (ref) => Supabase.instance.client.auth.currentUser?.id,
);

// ===============================================================
// 내 친구 목록
// ===============================================================

final friendProvider = FutureProvider<List<SocialConnection>>((ref) async {
  final userId = ref.watch(socialGraphUserIdProvider);
  if (userId == null) return [];

  final supabase = ref.watch(socialGraphSupabaseProvider);

  final rows = await supabase
      .from('social_graph')
      .select()
      .eq('relation_type', 'friend')
      .or('from_user_id.eq.$userId,to_user_id.eq.$userId');

  return (rows as List).map((e) {
    final row = e as Map<String, dynamic>;
    return SocialConnection(
      id: row['id'] ?? '',
      fromUserId: row['from_user_id'] ?? '',
      toUserId: row['to_user_id'] ?? '',
      relationType: SocialRelationType.friend,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }).toList();
});

// ===============================================================
// 내 팔로우 목록
// ===============================================================

final followProvider = FutureProvider<List<SocialConnection>>((ref) async {
  final userId = ref.watch(socialGraphUserIdProvider);
  if (userId == null) return [];

  final supabase = ref.watch(socialGraphSupabaseProvider);

  final rows = await supabase
      .from('social_graph')
      .select()
      .eq('relation_type', 'follow')
      .eq('from_user_id', userId);

  return (rows as List).map((e) {
    final row = e as Map<String, dynamic>;
    return SocialConnection(
      id: row['id'] ?? '',
      fromUserId: row['from_user_id'] ?? '',
      toUserId: row['to_user_id'] ?? '',
      relationType: SocialRelationType.follow,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }).toList();
});

// ===============================================================
// 내 가족 목록
// ===============================================================

final familyProvider = FutureProvider<List<SocialConnection>>((ref) async {
  final userId = ref.watch(socialGraphUserIdProvider);
  if (userId == null) return [];

  final supabase = ref.watch(socialGraphSupabaseProvider);

  final rows = await supabase
      .from('social_graph')
      .select()
      .eq('relation_type', 'family')
      .or('from_user_id.eq.$userId,to_user_id.eq.$userId');

  return (rows as List).map((e) {
    final row = e as Map<String, dynamic>;
    return SocialConnection(
      id: row['id'] ?? '',
      fromUserId: row['from_user_id'] ?? '',
      toUserId: row['to_user_id'] ?? '',
      relationType: SocialRelationType.family,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }).toList();
});

// ===============================================================
// 친구 추가
// ===============================================================

final addFriendProvider = FutureProvider.family<void, String>((ref, toUserId) async {
  final userId = ref.watch(socialGraphUserIdProvider);
  if (userId == null) throw Exception('로그인이 필요합니다');

  final supabase = ref.watch(socialGraphSupabaseProvider);

  await supabase.from('social_graph').insert({
    'from_user_id': userId,
    'to_user_id': toUserId,
    'relation_type': 'friend',
  });

  ref.invalidate(friendProvider);
});

// ===============================================================
// 팔로우
// ===============================================================

final followUserProvider = FutureProvider.family<void, String>((ref, toUserId) async {
  final userId = ref.watch(socialGraphUserIdProvider);
  if (userId == null) throw Exception('로그인이 필요합니다');

  final supabase = ref.watch(socialGraphSupabaseProvider);

  await supabase.from('social_graph').upsert({
    'from_user_id': userId,
    'to_user_id': toUserId,
    'relation_type': 'follow',
  }, onConflict: 'from_user_id, to_user_id, relation_type');

  ref.invalidate(followProvider);
});

// ===============================================================
// 언팔로우
// ===============================================================

final unfollowUserProvider = FutureProvider.family<void, String>((ref, toUserId) async {
  final userId = ref.watch(socialGraphUserIdProvider);
  if (userId == null) throw Exception('로그인이 필요합니다');

  final supabase = ref.watch(socialGraphSupabaseProvider);

  await supabase
      .from('social_graph')
      .delete()
      .eq('from_user_id', userId)
      .eq('to_user_id', toUserId)
      .eq('relation_type', 'follow');

  ref.invalidate(followProvider);
});

// ===============================================================
// 추천 사용자 (간단 버전: 최근 걸음 많은 top 10)
// ===============================================================

class RecommendedUser {
  final String id;
  final String name;
  final int weeklySteps;

  const RecommendedUser({
    required this.id,
    required this.name,
    required this.weeklySteps,
  });
}

final recommendedUsersProvider = FutureProvider<List<RecommendedUser>>((ref) async {
  final userId = ref.watch(socialGraphUserIdProvider);
  if (userId == null) return [];

  final supabase = ref.watch(socialGraphSupabaseProvider);

  try {
    // 팔로우/친구 아닌 사용자 중 걸음 많은 top 10
    final rows = await supabase.rpc('get_health_weekly', params: {
      'p_user_id': userId,
      'p_start_date': DateTime.now().subtract(const Duration(days: 6)).toIso8601String().substring(0, 10),
    });

    return [];
  } catch (_) {
    return [];
  }
});
