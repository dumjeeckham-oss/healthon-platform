/// ===============================================================
/// HealthON — Supabase Admin Repository v3 (Production)
///
/// 회원 테이블: public.users (NOT profiles)
/// Storage / Realtime / Audit Log / Export 완전 통합
/// ===============================================================

library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_models.dart';

class SupabaseAdminRepository {
  final SupabaseClient _client;

  SupabaseAdminRepository(this._client);

  // =============================================================
  // Storage Buckets
  // =============================================================

  static const _storageBuckets = [
    'community-images',
    'banner-images',
    'mission-images',
    'challenge-images',
    'forest-images',
  ];

  Future<void> ensureStorageBuckets() async {
    for (final bucket in _storageBuckets) {
      try {
        await _client.storage.createBucket(bucket, const BucketOptions(public: true));
      } catch (_) {
        // bucket already exists — ok
      }
    }
  }

  Future<String> uploadImage({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final filePath = '$path/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from(bucket).uploadBinary(
      filePath, bytes,
      fileOptions: FileOptions(contentType: contentType ?? 'image/jpeg'),
    );
    return _client.storage.from(bucket).getPublicUrl(filePath);
  }

  Future<void> deleteImage(String bucket, String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(bucket);
      if (bucketIndex >= 0 && bucketIndex + 1 < segments.length) {
        final filePath = segments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(bucket).remove([filePath]);
      }
    } catch (_) {}
  }

  Future<void> deleteImages(String bucket, List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteImage(bucket, url);
    }
  }

  // =============================================================
  // Realtime
  // =============================================================

  Stream<AdminRealtimeEvent<Map<String, dynamic>>> subscribeToTable(String table) {
    final channel = _client.channel('admin_$table');
    final controller = StreamController<AdminRealtimeEvent<Map<String, dynamic>>>();

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      callback: (payload) {
        controller.add(AdminRealtimeEvent(
          eventType: payload.eventType.name,
          table: table,
          oldRecord: payload.oldRecord,
          newRecord: payload.newRecord,
        ));
      },
    ).subscribe();

    controller.onCancel = () { _client.removeChannel(channel); };
    return controller.stream;
  }

  // =============================================================
  // Audit Log
  // =============================================================

  Future<void> _logAudit({
    required String adminId, required String adminName,
    required AuditAction action, required String targetType,
    String? targetId, String? targetName, Map<String, dynamic>? changes,
  }) async {
    try {
      await _client.from('audit_log').insert({
        'admin_id': adminId, 'admin_name': adminName,
        'action': action.name, 'target_type': targetType,
        'target_id': targetId, 'target_name': targetName,
        'changes': changes,
      });
    } catch (_) {}
  }

  Future<List<AuditLogEntry>> getAuditLog({int limit = 100}) async {
    final rows = await _client.from('audit_log').select().order('created_at', ascending: false).limit(limit);
    return (rows as List).map((e) => AuditLogEntry.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<({String id, String name})> _getCurrentAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) return (id: '', name: 'Unknown');
    try {
      final row = await _client.from('users').select('name').eq('id', user.id).maybeSingle();
      return (id: user.id, name: (row?['name'] ?? user.email ?? 'Unknown') as String);
    } catch (_) {
      return (id: user.id, name: user.email ?? 'Unknown');
    }
  }

  // =============================================================
  // Dashboard
  // =============================================================

  Future<AdminDashboardStats> getDashboardStats() async {
    final today = DateTime.now();
    final todayStr = _dateStr(today);

    final results = await Future.wait([
      _client.from('users').select('id').gte('created_at', todayStr),
      _client.from('users').select('id').gte('last_login_at', todayStr),
      _client.from('health_daily').select('steps.sum(), distance_km.sum()').eq('date', todayStr),
      _client.from('community_posts').select('id').gte('created_at', todayStr),
      _client.from('community_comments').select('id').gte('created_at', todayStr),
      _client.from('users').select('id, is_suspended'),
      _client.from('activity_events').select('id').eq('type', 'challenge_completed').gte('created_at', todayStr),
      _client.from('activity_events').select('id').eq('type', 'mission_completed').gte('created_at', todayStr),
      _client.from('activity_events').select('id').eq('type', 'forest_level_up').gte('created_at', todayStr),
      _client.from('challenge_definitions').select('id, is_active'),
      _client.from('community_reports').select('id').eq('status', 'pending'),
    ]);

    final users = results[5] as List;
    var activeUsers = 0, suspendedUsers = 0;
    for (final u in users) {
      if (u['is_suspended'] == true) { suspendedUsers++; } else { activeUsers++; }
    }

    return AdminDashboardStats(
      todaySignups: (results[0] as List).length,
      todayLogins: (results[1] as List).length,
      todaySteps: ((results[2] as List).firstOrNull?['sum'] ?? 0) as int,
      todayPosts: (results[3] as List).length,
      todayComments: (results[4] as List).length,
      todayChallengeCompletions: (results[6] as List).length,
      todayMissionCompletions: (results[7] as List).length,
      todayForestGrowth: (results[8] as List).length,
      totalUsers: users.length, activeUsers: activeUsers, suspendedUsers: suspendedUsers,
      totalChallenges: (results[9] as List).length,
      activeChallenges: (results[9] as List).where((c) => c['is_active'] == true).length,
      pendingReports: (results[10] as List).length,
    );
  }

  Future<AdminChartData> getWeeklyStepsChart() => _getWeeklyChart('health_daily', 'steps', false, '걸음 수');
  Future<AdminChartData> getDailyUsersChart() => _getWeeklyChart('health_daily', 'user_id', true, '사용자 수');

  Future<AdminChartData> _getWeeklyChart(String table, String field, bool isCount, String yLabel) async {
    final now = DateTime.now();
    final labels = <String>[], values = <double>[];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateStr = _dateStr(d);
      labels.add('${d.month}/${d.day}');
      if (isCount) {
        final raw = await _client.from(table).select(field).eq('date', dateStr);
        values.add((raw as List).length.toDouble());
      } else {
        final raw = await _client.from(table).select('$field.sum()').eq('date', dateStr);
        values.add(((raw as List).firstOrNull?['sum'] ?? 0).toDouble());
      }
    }
    return AdminChartData(labels: labels, values: values, yLabel: yLabel);
  }

  String _dateStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // =============================================================
  // Members (public.users)
  // =============================================================

  Future<List<AdminMember>> getMembers({MemberFilter? filter, int limit = 50, int offset = 0}) async {
    final ascending = (filter?.sortOrder ?? MemberSortOrder.desc) == MemberSortOrder.asc;
    final rows = await _client.from('users').select('id, email, name, nickname, phone, photo_url, is_admin, is_suspended, created_at, last_login_at').order('created_at', ascending: ascending).range(offset, offset + limit - 1);
    return (rows as List).map((e) {
      final row = e as Map<String, dynamic>;
      return AdminMember.fromSupabase({...row, 'user_id': row['id'], 'avatar_url': row['photo_url']});
    }).toList();
  }

  Future<void> grantAdmin(String userId) async {
    final admin = await _getCurrentAdmin();
    await _client.from('users').update({'is_admin': true}).eq('id', userId);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.grantedAdmin, targetType: 'member', targetId: userId);
  }

  Future<void> revokeAdmin(String userId) async {
    final admin = await _getCurrentAdmin();
    await _client.from('users').update({'is_admin': false}).eq('id', userId);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.revokedAdmin, targetType: 'member', targetId: userId);
  }

  Future<void> suspendMember(String userId) async {
    final admin = await _getCurrentAdmin();
    await _client.from('users').update({'is_suspended': true}).eq('id', userId);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.suspended, targetType: 'member', targetId: userId);
  }

  Future<void> restoreMember(String userId) async {
    final admin = await _getCurrentAdmin();
    await _client.from('users').update({'is_suspended': false}).eq('id', userId);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.restored, targetType: 'member', targetId: userId);
  }

  // =============================================================
  // Notices
  // =============================================================

  Future<List<AdminNotice>> getNotices({String? category, int limit = 50}) async {
    final rows = await _client.from('admin_notices').select()
        .order('is_pinned', ascending: false).order('created_at', ascending: false).limit(limit);
    final notices = (rows as List).map((e) => AdminNotice.fromSupabase(e as Map<String, dynamic>));
    if (category != null && category.isNotEmpty) {
      return notices.where((n) => n.category == category).toList();
    }
    return notices.toList();
  }

  Future<AdminNotice?> getNotice(String id) async {
    final rows = await _client.from('admin_notices').select().limit(1);
    final row = (rows as List).cast<Map<String, dynamic>>().firstWhere(
      (r) => r['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    return row.isNotEmpty ? AdminNotice.fromSupabase(row) : null;
  }

  Future<AdminNotice> createNotice(AdminNotice notice) async {
    final admin = await _getCurrentAdmin();
    final data = notice.toSupabase();
    if (notice.isPublished && notice.publishedAt == null) {
      data['published_at'] = DateTime.now().toUtc().toIso8601String();
    }
    final result = await _client.from('admin_notices').insert(data).select().single();
    final created = AdminNotice.fromSupabase(result);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: notice.isPublished ? AuditAction.published : AuditAction.created, targetType: 'notice', targetId: created.id, targetName: created.title);
    return created;
  }

  Future<void> updateNotice(AdminNotice notice) async {
    final admin = await _getCurrentAdmin();
    final data = notice.toSupabase();
    if (notice.isPublished && notice.publishedAt == null) data['published_at'] = DateTime.now().toUtc().toIso8601String();
    await _client.from('admin_notices').update(data).eq('id', notice.id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.updated, targetType: 'notice', targetId: notice.id, targetName: notice.title);
  }

  Future<void> deleteNotice(String id) async {
    final admin = await _getCurrentAdmin();
    final notice = await getNotice(id);
    await _client.from('admin_notices').delete().eq('id', id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.deleted, targetType: 'notice', targetId: id, targetName: notice?.title);
  }

  Future<void> sendPushForNotice(String noticeId) async {
    final admin = await _getCurrentAdmin();
    await _client.rpc('send_notice_push', params: {'p_notice_id': noticeId});
    await _client.from('admin_notices').update({'push_sent': true}).eq('id', noticeId);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.sentPush, targetType: 'notice', targetId: noticeId);
  }

  // =============================================================
  // Reports
  // =============================================================

  Future<List<AdminReport>> getReports({ReportStatus? status, int limit = 50}) async {
    final rows = await _client.from('community_reports').select('''
      id, reporter_id, target_type, target_id, reason, detail, status,
      target_content, target_author_id, resolved_action, resolved_by,
      created_at, resolved_at, reporter_name
    ''').order('created_at', ascending: false).limit(limit);

    final reports = (rows as List).map((e) {
      final row = e as Map<String, dynamic>;
      return AdminReport(
        id: row['id'] ?? '', reporterId: row['reporter_id'] ?? '',
        reporterName: row['reporter_name'] ?? '알 수 없음',
        targetType: row['target_type'] ?? 'post', targetId: row['target_id'] ?? '',
        targetContent: row['target_content'], targetAuthorId: row['target_author_id'],
        reason: row['reason'] ?? '', detail: row['detail'],
        status: _parseReportStatus(row['status'] as String?),
        resolvedAction: row['resolved_action'], resolvedBy: row['resolved_by'],
        createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
        resolvedAt: row['resolved_at'] != null ? DateTime.parse(row['resolved_at']) : null,
      );
    }).toList();

    if (status != null) {
      return reports.where((r) => r.status == status).toList();
    }
    return reports;
  }

  Future<void> resolveReport(String reportId, ReportStatus status) async {
    final admin = await _getCurrentAdmin();
    await _client.from('community_reports').update({
      'status': status.name, 'resolved_action': status.name,
      'resolved_by': admin.name, 'resolved_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', reportId);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.resolvedReport, targetType: 'report', targetId: reportId);
  }

  // =============================================================
  // Challenges
  // =============================================================

  Future<List<AdminChallengeDefinition>> getChallenges() async {
    final rows = await _client.from('challenge_definitions').select().order('start_date', ascending: false);
    return (rows as List).map((e) => AdminChallengeDefinition.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<AdminChallengeDefinition> createChallenge(AdminChallengeDefinition c) async {
    final admin = await _getCurrentAdmin();
    final result = await _client.from('challenge_definitions').insert(c.toSupabase()).select().single();
    final created = AdminChallengeDefinition.fromSupabase(result);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.created, targetType: 'challenge', targetId: created.id, targetName: created.title);
    return created;
  }

  Future<void> updateChallenge(AdminChallengeDefinition c) async {
    final admin = await _getCurrentAdmin();
    await _client.from('challenge_definitions').update(c.toSupabase()).eq('id', c.id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.updated, targetType: 'challenge', targetId: c.id, targetName: c.title);
  }

  Future<void> deleteChallenge(String id) async {
    final admin = await _getCurrentAdmin();
    await _client.from('challenge_definitions').delete().eq('id', id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.deleted, targetType: 'challenge', targetId: id);
  }

  // =============================================================
  // Missions
  // =============================================================

  Future<List<AdminMissionDefinition>> getMissions() async {
    final rows = await _client.from('mission_definitions').select().order('created_at', ascending: false);
    return (rows as List).map((e) => AdminMissionDefinition.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<AdminMissionDefinition> createMission(AdminMissionDefinition m) async {
    final admin = await _getCurrentAdmin();
    final result = await _client.from('mission_definitions').insert({
      'title': m.title, 'description': m.description, 'image_url': m.imageUrl,
      'period': m.period.name, 'custom_days': m.customDays,
      'target_steps': m.targetSteps, 'target_distance_km': m.targetDistanceKm,
      'condition': m.condition?.toJson(), 'reward_type': m.rewardType,
      'reward_value': m.rewardValue, 'is_repeatable': m.isRepeatable, 'is_active': m.isActive,
    }).select().single();
    final created = AdminMissionDefinition.fromSupabase(result);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.created, targetType: 'mission', targetId: created.id, targetName: created.title);
    return created;
  }

  Future<void> updateMission(AdminMissionDefinition m) async {
    final admin = await _getCurrentAdmin();
    await _client.from('mission_definitions').update({
      'title': m.title, 'description': m.description, 'image_url': m.imageUrl,
      'period': m.period.name, 'custom_days': m.customDays,
      'target_steps': m.targetSteps, 'target_distance_km': m.targetDistanceKm,
      'condition': m.condition?.toJson(), 'reward_type': m.rewardType,
      'reward_value': m.rewardValue, 'is_repeatable': m.isRepeatable, 'is_active': m.isActive,
    }).eq('id', m.id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.updated, targetType: 'mission', targetId: m.id, targetName: m.title);
  }

  Future<void> deleteMission(String id) async {
    final admin = await _getCurrentAdmin();
    await _client.from('mission_definitions').delete().eq('id', id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.deleted, targetType: 'mission', targetId: id);
  }

  // =============================================================
  // Forest Seasons
  // =============================================================

  Future<List<AdminForestSeason>> getForestSeasons() async {
    final rows = await _client.from('forest_seasons').select().order('start_date', ascending: false);
    return (rows as List).map((e) => AdminForestSeason.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<AdminForestSeason> createSeason(AdminForestSeason s) async {
    final admin = await _getCurrentAdmin();
    await _client.from('forest_seasons').update({'is_active': false, 'end_date': DateTime.now().toIso8601String().substring(0, 10)}).eq('is_active', true);
    final result = await _client.from('forest_seasons').insert(s.toSupabase()).select().single();
    final created = AdminForestSeason.fromSupabase(result);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.created, targetType: 'season', targetId: created.id, targetName: created.name);
    return created;
  }

  Future<void> endSeason(String id) async {
    final admin = await _getCurrentAdmin();
    await _client.from('forest_seasons').update({'is_active': false, 'end_date': DateTime.now().toIso8601String().substring(0, 10)}).eq('id', id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.endedSeason, targetType: 'season', targetId: id);
  }

  // =============================================================
  // Banners
  // =============================================================

  Future<List<AdminBanner>> getBanners() async {
    final rows = await _client.from('admin_banners').select().order('sort_order');
    return (rows as List).map((e) => AdminBanner.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<AdminBanner> createBanner(AdminBanner b) async {
    final admin = await _getCurrentAdmin();
    final result = await _client.from('admin_banners').insert({
      'title': b.title, 'image_url': b.imageUrl, 'link_value': b.linkValue,
      'link_type': b.linkType.name, 'sort_order': b.sortOrder,
      'start_date': b.startDate.toIso8601String().substring(0, 10),
      'end_date': b.endDate.toIso8601String().substring(0, 10), 'is_active': b.isActive,
    }).select().single();
    final created = AdminBanner.fromSupabase(result);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.created, targetType: 'banner', targetId: created.id, targetName: created.title);
    return created;
  }

  Future<void> updateBanner(AdminBanner b) async {
    final admin = await _getCurrentAdmin();
    await _client.from('admin_banners').update({
      'title': b.title, 'image_url': b.imageUrl, 'link_value': b.linkValue,
      'link_type': b.linkType.name, 'sort_order': b.sortOrder,
      'start_date': b.startDate.toIso8601String().substring(0, 10),
      'end_date': b.endDate.toIso8601String().substring(0, 10), 'is_active': b.isActive,
    }).eq('id', b.id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.updated, targetType: 'banner', targetId: b.id, targetName: b.title);
  }

  Future<void> deleteBanner(String id) async {
    final admin = await _getCurrentAdmin();
    await _client.from('admin_banners').delete().eq('id', id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.deleted, targetType: 'banner', targetId: id);
  }

  Future<void> reorderBanners(List<String> orderedIds) async {
    final admin = await _getCurrentAdmin();
    for (var i = 0; i < orderedIds.length; i++) {
      await _client.from('admin_banners').update({'sort_order': i}).eq('id', orderedIds[i]);
    }
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.reordered, targetType: 'banner');
  }

  Future<void> toggleBanner(String id, bool active) async {
    await _client.from('admin_banners').update({'is_active': active}).eq('id', id);
  }

  // =============================================================
  // Corporate News
  // =============================================================

  Future<List<CorporateNews>> getCorporateNews({int limit = 50}) async {
    final rows = await _client.from('admin_corporate_news').select().order('created_at', ascending: false).limit(limit);
    return (rows as List).map((e) => CorporateNews.fromSupabase(e as Map<String, dynamic>)).toList();
  }

  Future<CorporateNews> createCorporateNews(CorporateNews news) async {
    final admin = await _getCurrentAdmin();
    final result = await _client.from('admin_corporate_news').insert(news.toSupabase()).select().single();
    final created = CorporateNews.fromSupabase(result);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.created, targetType: 'corporate_news', targetId: created.id, targetName: created.title);
    return created;
  }

  Future<void> updateCorporateNews(CorporateNews news) async {
    final admin = await _getCurrentAdmin();
    await _client.from('admin_corporate_news').update(news.toSupabase()).eq('id', news.id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.updated, targetType: 'corporate_news', targetId: news.id, targetName: news.title);
  }

  Future<void> deleteCorporateNews(String id) async {
    final admin = await _getCurrentAdmin();
    await _client.from('admin_corporate_news').delete().eq('id', id);
    await _logAudit(adminId: admin.id, adminName: admin.name, action: AuditAction.deleted, targetType: 'corporate_news', targetId: id);
  }

  // =============================================================
  // Export
  // =============================================================

  String exportMembersToCsv(List<AdminMember> members) {
    final buffer = StringBuffer();
    buffer.writeln('이름,이메일,닉네임,전화번호,관리자,정지,가입일,최종로그인,총걸음,총거리(km),Forest레벨');

    for (final m in members) {
      buffer.writeln('${_csvEscape(m.name)},${_csvEscape(m.email)},'
          '${_csvEscape(m.nickname ?? '')},${_csvEscape(m.phone ?? '')},'
          '${m.isAdmin ? 'Y' : 'N'},${m.isSuspended ? 'Y' : 'N'},'
          '${_dateStr(m.createdAt)},${m.lastLoginAt != null ? _dateStr(m.lastLoginAt!) : ''},'
          '${m.totalSteps},${m.totalDistanceKm.toStringAsFixed(1)},${m.forestLevel}');
    }
    return buffer.toString();
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static ReportStatus _parseReportStatus(String? status) {
    switch (status) {
      case 'reviewed':
        return ReportStatus.reviewed;
      case 'deleted':
        return ReportStatus.deleted;
      case 'hidden':
        return ReportStatus.hidden;
      case 'warned':
        return ReportStatus.warned;
      case 'suspended':
        return ReportStatus.suspended;
      default:
        return ReportStatus.pending;
    }
  }
}
