/// ===============================================================
/// HealthON — Family Repository
///
/// 가족 생성/가입/랭킹/응원/챌린지
/// ===============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

class FamilyInfo {
  final String id;
  final String name;
  final String description;
  final String inviteCode;
  final String leaderId;
  final int memberCount;
  final int totalSteps;
  final double totalDistanceKm;
  final int forestLevel;
  final int weeklyGoal;
  final bool isActive;
  final DateTime createdAt;

  const FamilyInfo({
    required this.id, required this.name, required this.description,
    required this.inviteCode, required this.leaderId, this.memberCount = 1,
    this.totalSteps = 0, this.totalDistanceKm = 0, this.forestLevel = 1,
    this.weeklyGoal = 70000, this.isActive = true, required this.createdAt,
  });

  factory FamilyInfo.fromSupabase(Map<String, dynamic> row) => FamilyInfo(
    id: row['id'] ?? '', name: row['name'] ?? '', description: row['description'] ?? '',
    inviteCode: row['invite_code'] ?? '', leaderId: row['leader_id'] ?? '',
    memberCount: row['member_count'] as int? ?? 1, totalSteps: row['total_steps'] as int? ?? 0,
    totalDistanceKm: (row['total_distance_km'] as num?)?.toDouble() ?? 0,
    forestLevel: row['forest_level'] as int? ?? 1, weeklyGoal: row['weekly_goal'] as int? ?? 70000,
    isActive: row['is_active'] == true,
    createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
  );
}

class FamilyMemberInfo {
  final String userId;
  final String? name;
  final String? photoUrl;
  final String role;
  final String status;
  final DateTime joinedAt;

  const FamilyMemberInfo({required this.userId, this.name, this.photoUrl, required this.role, required this.status, required this.joinedAt});

  factory FamilyMemberInfo.fromSupabase(Map<String, dynamic> row) => FamilyMemberInfo(
    userId: row['user_id'] ?? '', name: row['name'] as String?, photoUrl: row['photo_url'] as String?,
    role: row['role'] ?? 'member', status: row['status'] ?? 'active',
    joinedAt: row['joined_at'] != null ? DateTime.parse(row['joined_at']) : DateTime.now(),
  );

  bool get isLeader => role == 'leader';
  bool get isActive => status == 'active';
}

class FamilyRankingEntry {
  final String userId;
  final String? name;
  final String? photoUrl;
  final int todaySteps;
  final int weeklySteps;
  final int forestLevel;
  final int streak;

  const FamilyRankingEntry({required this.userId, this.name, this.photoUrl, this.todaySteps = 0, this.weeklySteps = 0, this.forestLevel = 1, this.streak = 0});
}

class FamilyCheer {
  final String id;
  final String familyId;
  final String fromUserId;
  final String toUserId;
  final String message;
  final DateTime createdAt;

  const FamilyCheer({required this.id, required this.familyId, required this.fromUserId, required this.toUserId, this.message = '응원해요! 💪', required this.createdAt});
}

class FamilyRepository {
  final SupabaseClient _client;
  FamilyRepository(this._client);

  // =============================================================
  // Family CRUD
  // =============================================================

  Future<FamilyInfo?> getMyFamily() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final memberRow = await _client.from('family_members').select('family_id').eq('user_id', userId).eq('status', 'active').maybeSingle();
      if (memberRow == null) return null;
      final familyRow = await _client.from('families').select().eq('id', memberRow['family_id']).maybeSingle();
      return familyRow != null ? FamilyInfo.fromSupabase(familyRow) : null;
    } catch (_) {
      return null;
    }
  }

  Future<FamilyInfo> createFamily({required String name, String description = ''}) async {
    final userId = _client.auth.currentUser!.id;
    final inviteCode = _generateCode();
    final result = await _client.from('families').insert({
      'name': name, 'description': description, 'invite_code': inviteCode,
      'leader_id': userId, 'member_count': 1,
    }).select().single();
    // 가족장도 member 등록
    await _client.from('family_members').insert({'family_id': result['id'], 'user_id': userId, 'role': 'leader', 'status': 'active'});
    await _client.from('users').update({'family_id': result['id'].toString()}).eq('id', userId);
    return FamilyInfo.fromSupabase(result);
  }

  Future<bool> joinFamily(String inviteCode) async {
    try {
      await _client.rpc('join_family_by_code', params: {'p_code': inviteCode, 'p_user_id': _client.auth.currentUser!.id});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<FamilyMemberInfo>> getFamilyMembers(String familyId) async {
    final rows = await _client.from('family_members').select('user_id, role, status, joined_at, users!inner(name, photo_url)').eq('family_id', familyId).order('joined_at');
    return (rows as List).map((e) {
      final row = e as Map<String, dynamic>;
      return FamilyMemberInfo(userId: row['user_id'] ?? '', name: row['users']?['name'], photoUrl: row['users']?['photo_url'], role: row['role'] ?? 'member', status: row['status'] ?? 'active', joinedAt: row['joined_at'] != null ? DateTime.parse(row['joined_at']) : DateTime.now());
    }).toList();
  }

  Future<void> leaveFamily(String familyId) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('family_members').update({'status': 'left'}).eq('family_id', familyId).eq('user_id', userId);
    await _client.from('families').update({'member_count': _client.from('family_members').select('id').eq('family_id', familyId).eq('status', 'active').count(CountOption.exact)}).eq('id', familyId);
  }

  // =============================================================
  // Ranking
  // =============================================================

  Future<List<FamilyRankingEntry>> getFamilyRanking(String familyId) async {
    try {
      final rows = await _client.rpc('get_family_ranking', params: {'p_family_id': familyId});
      return (rows as List).map((e) {
        final row = e as Map<String, dynamic>;
        return FamilyRankingEntry(userId: row['user_id'] ?? '', name: row['name'], photoUrl: row['photo_url'], todaySteps: (row['today_steps'] ?? 0) as int, weeklySteps: (row['weekly_steps'] ?? 0) as int, forestLevel: row['forest_level'] as int? ?? 1, streak: row['streak'] as int? ?? 0);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // =============================================================
  // Cheers
  // =============================================================

  Future<void> sendCheer({required String familyId, required String toUserId, String message = '응원해요! 💪'}) async {
    await _client.from('family_cheers').insert({'family_id': familyId, 'from_user_id': _client.auth.currentUser!.id, 'to_user_id': toUserId, 'message': message});
  }

  Future<List<FamilyCheer>> getCheers(String familyId, {int limit = 20}) async {
    final rows = await _client.from('family_cheers').select().eq('family_id', familyId).order('created_at', ascending: false).limit(limit);
    return (rows as List).map((e) {
      final row = e as Map<String, dynamic>;
      return FamilyCheer(id: row['id'] ?? '', familyId: row['family_id'] ?? '', fromUserId: row['from_user_id'] ?? '', toUserId: row['to_user_id'] ?? '', message: row['message'] ?? '응원해요! 💪', createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now());
    }).toList();
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final now = DateTime.now().microsecondsSinceEpoch;
    return List.generate(6, (i) => chars[(now >> (i * 5)) % chars.length]).join();
  }
}
