/// ===============================================================
/// HealthON — Admin Provider v2 (StateNotifier + Optimistic)
///
/// FutureProvider 제거, StateNotifierProvider 기반
/// Optimistic update / invalidate 최소화 / Realtime 지원
/// ===============================================================

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_models.dart';
import 'supabase_admin_repository.dart';

// ===============================================================
// Supabase Client + Repository
// ===============================================================

final adminSupabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final adminRepositoryProvider = Provider<SupabaseAdminRepository>(
  (ref) => SupabaseAdminRepository(ref.watch(adminSupabaseProvider)),
);

// ===============================================================
// 관리자 정보
// ===============================================================

final currentAdminProvider = FutureProvider<({String id, String name})?>((ref) async {
  final client = ref.watch(adminSupabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;
  try {
    final row = await client.from('users').select('name').eq('id', user.id).maybeSingle();
    return (id: user.id, name: (row?['name'] ?? user.email ?? 'Unknown') as String);
  } catch (_) {
    return (id: user.id, name: user.email ?? 'Unknown');
  }
});

// ===============================================================
// Dashboard (StateNotifier → 한 번 로드, 수동 refresh)
// ===============================================================

class AdminDashboardNotifier extends StateNotifier<AsyncValue<AdminDashboardStats>> {
  final SupabaseAdminRepository _repo;
  bool _initialized = false;

  AdminDashboardNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load() async {
    if (!_initialized) {
      state = const AsyncValue.loading();
    }
    try {
      final stats = await _repo.getDashboardStats();
      state = AsyncValue.data(stats);
      _initialized = true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminDashboardProvider = StateNotifierProvider<AdminDashboardNotifier, AsyncValue<AdminDashboardStats>>((ref) {
  return AdminDashboardNotifier(ref.watch(adminRepositoryProvider));
});

// ===============================================================
// Members — StateNotifier + Optimistic Update
// ===============================================================

class AdminMembersNotifier extends StateNotifier<AsyncValue<List<AdminMember>>> {
  final SupabaseAdminRepository _repo;

  AdminMembersNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load({MemberFilter? filter}) async {
    state = const AsyncValue.loading();
    try {
      final members = await _repo.getMembers(filter: filter);
      state = AsyncValue.data(members);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> grantAdmin(String userId) async {
    _optimisticUpdate(userId, (m) => AdminMember.fromSupabase({
      'user_id': m.userId,
      'email': m.email,
      'name': m.name,
      'nickname': m.nickname,
      'phone': m.phone,
      'avatar_url': m.avatarUrl,
      'is_admin': true,
      'is_suspended': m.isSuspended,
      'created_at': m.createdAt.toIso8601String(),
      'last_login_at': m.lastLoginAt?.toIso8601String(),
      'total_steps': m.totalSteps,
      'total_distance_km': m.totalDistanceKm,
      'tree_level': m.forestLevel,
      'tree_type': m.forestTreeType,
    }));
    try {
      await _repo.grantAdmin(userId);
    } catch (_) {
      await load(); // rollback by reloading
    }
  }

  Future<void> revokeAdmin(String userId) async {
    _optimisticUpdate(userId, (m) => AdminMember.fromSupabase({
      'user_id': m.userId,
      'email': m.email,
      'name': m.name,
      'nickname': m.nickname,
      'phone': m.phone,
      'avatar_url': m.avatarUrl,
      'is_admin': false,
      'is_suspended': m.isSuspended,
      'created_at': m.createdAt.toIso8601String(),
      'last_login_at': m.lastLoginAt?.toIso8601String(),
      'total_steps': m.totalSteps,
      'total_distance_km': m.totalDistanceKm,
      'tree_level': m.forestLevel,
      'tree_type': m.forestTreeType,
    }));
    try {
      await _repo.revokeAdmin(userId);
    } catch (_) {
      await load();
    }
  }

  Future<void> suspendMember(String userId) async {
    _optimisticUpdate(userId, (m) => AdminMember.fromSupabase({
      'user_id': m.userId,
      'email': m.email,
      'name': m.name,
      'nickname': m.nickname,
      'phone': m.phone,
      'avatar_url': m.avatarUrl,
      'is_admin': m.isAdmin,
      'is_suspended': true,
      'created_at': m.createdAt.toIso8601String(),
      'last_login_at': m.lastLoginAt?.toIso8601String(),
      'total_steps': m.totalSteps,
      'total_distance_km': m.totalDistanceKm,
      'tree_level': m.forestLevel,
      'tree_type': m.forestTreeType,
    }));
    try {
      await _repo.suspendMember(userId);
    } catch (_) {
      await load();
    }
  }

  Future<void> restoreMember(String userId) async {
    _optimisticUpdate(userId, (m) => AdminMember.fromSupabase({
      'user_id': m.userId,
      'email': m.email,
      'name': m.name,
      'nickname': m.nickname,
      'phone': m.phone,
      'avatar_url': m.avatarUrl,
      'is_admin': m.isAdmin,
      'is_suspended': false,
      'created_at': m.createdAt.toIso8601String(),
      'last_login_at': m.lastLoginAt?.toIso8601String(),
      'total_steps': m.totalSteps,
      'total_distance_km': m.totalDistanceKm,
      'tree_level': m.forestLevel,
      'tree_type': m.forestTreeType,
    }));
    try {
      await _repo.restoreMember(userId);
    } catch (_) {
      await load();
    }
  }

  void _optimisticUpdate(String userId, AdminMember Function(AdminMember) transform) {
    state.whenData((members) {
      final updated = members.map((m) => m.userId == userId ? transform(m) : m).toList();
      state = AsyncValue.data(updated);
    });
  }
}

final adminMembersProvider = StateNotifierProvider<AdminMembersNotifier, AsyncValue<List<AdminMember>>>((ref) {
  return AdminMembersNotifier(ref.watch(adminRepositoryProvider));
});

// ===============================================================
// Notices — StateNotifier + Optimistic
// ===============================================================

class AdminNoticesNotifier extends StateNotifier<AsyncValue<List<AdminNotice>>> {
  final SupabaseAdminRepository _repo;

  AdminNoticesNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load({String? category}) async {
    state = const AsyncValue.loading();
    try {
      final notices = await _repo.getNotices(category: category);
      state = AsyncValue.data(notices);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createNotice(AdminNotice notice) async {
    state.whenData((notices) {
      state = AsyncValue.data([notice, ...notices]);
    });
    try {
      final created = await _repo.createNotice(notice);
      state.whenData((notices) {
        state = AsyncValue.data(
          notices.map((n) => n.id == notice.id ? created : n).toList(),
        );
      });
    } catch (_) {
      await load();
    }
  }

  Future<void> updateNotice(AdminNotice notice) async {
    state.whenData((notices) {
      state = AsyncValue.data(
        notices.map((n) => n.id == notice.id ? notice : n).toList(),
      );
    });
    try {
      await _repo.updateNotice(notice);
    } catch (_) {
      await load();
    }
  }

  Future<void> deleteNotice(String id) async {
    state.whenData((notices) {
      state = AsyncValue.data(notices.where((n) => n.id != id).toList());
    });
    try {
      await _repo.deleteNotice(id);
    } catch (_) {
      await load();
    }
  }
}

final adminNoticesProvider = StateNotifierProvider<AdminNoticesNotifier, AsyncValue<List<AdminNotice>>>((ref) {
  return AdminNoticesNotifier(ref.watch(adminRepositoryProvider));
});

// ===============================================================
// Reports — StateNotifier + Optimistic
// ===============================================================

class AdminReportsNotifier extends StateNotifier<AsyncValue<List<AdminReport>>> {
  final SupabaseAdminRepository _repo;

  AdminReportsNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load({ReportStatus? status}) async {
    state = const AsyncValue.loading();
    try {
      final reports = await _repo.getReports(status: status);
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resolveReport(String reportId, ReportStatus status) async {
    state.whenData((reports) {
      state = AsyncValue.data(
        reports.map((r) => r.id == reportId
            ? AdminReport(
                id: r.id,
                reporterId: r.reporterId,
                reporterName: r.reporterName,
                targetType: r.targetType,
                targetId: r.targetId,
                targetContent: r.targetContent,
                targetAuthorId: r.targetAuthorId,
                targetAuthorName: r.targetAuthorName,
                reason: r.reason,
                detail: r.detail,
                status: status,
                resolvedAt: DateTime.now(),
                createdAt: r.createdAt,
              )
            : r).toList(),
      );
    });
    try {
      await _repo.resolveReport(reportId, status);
    } catch (_) {
      await load();
    }
  }
}

final adminReportsProvider = StateNotifierProvider<AdminReportsNotifier, AsyncValue<List<AdminReport>>>((ref) {
  return AdminReportsNotifier(ref.watch(adminRepositoryProvider));
});

// ===============================================================
// Challenges — StateNotifier + Optimistic
// ===============================================================

class AdminChallengesNotifier extends StateNotifier<AsyncValue<List<AdminChallengeDefinition>>> {
  final SupabaseAdminRepository _repo;

  AdminChallengesNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final challenges = await _repo.getChallenges();
      state = AsyncValue.data(challenges);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createChallenge(AdminChallengeDefinition c) async {
    state.whenData((challenges) {
      state = AsyncValue.data([c, ...challenges]);
    });
    try {
      final created = await _repo.createChallenge(c);
      state.whenData((challenges) {
        state = AsyncValue.data(
          challenges.map((ch) => ch.id == c.id ? created : ch).toList(),
        );
      });
    } catch (_) {
      await load();
    }
  }

  Future<void> updateChallenge(AdminChallengeDefinition c) async {
    state.whenData((challenges) {
      state = AsyncValue.data(
        challenges.map((ch) => ch.id == c.id ? c : ch).toList(),
      );
    });
    try {
      await _repo.updateChallenge(c);
    } catch (_) {
      await load();
    }
  }

  Future<void> deleteChallenge(String id) async {
    state.whenData((challenges) {
      state = AsyncValue.data(challenges.where((c) => c.id != id).toList());
    });
    try {
      await _repo.deleteChallenge(id);
    } catch (_) {
      await load();
    }
  }
}

final adminChallengesProvider = StateNotifierProvider<AdminChallengesNotifier, AsyncValue<List<AdminChallengeDefinition>>>((ref) {
  return AdminChallengesNotifier(ref.watch(adminRepositoryProvider));
});

// ===============================================================
// Missions — StateNotifier + Optimistic
// ===============================================================

class AdminMissionsNotifier extends StateNotifier<AsyncValue<List<AdminMissionDefinition>>> {
  final SupabaseAdminRepository _repo;

  AdminMissionsNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final missions = await _repo.getMissions();
      state = AsyncValue.data(missions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createMission(AdminMissionDefinition m) async {
    state.whenData((missions) {
      state = AsyncValue.data([m, ...missions]);
    });
    try {
      final created = await _repo.createMission(m);
      state.whenData((missions) {
        state = AsyncValue.data(
          missions.map((ms) => ms.id == m.id ? created : ms).toList(),
        );
      });
    } catch (_) {
      await load();
    }
  }

  Future<void> updateMission(AdminMissionDefinition m) async {
    state.whenData((missions) {
      state = AsyncValue.data(
        missions.map((ms) => ms.id == m.id ? m : ms).toList(),
      );
    });
    try {
      await _repo.updateMission(m);
    } catch (_) {
      await load();
    }
  }

  Future<void> deleteMission(String id) async {
    state.whenData((missions) {
      state = AsyncValue.data(missions.where((m) => m.id != id).toList());
    });
    try {
      await _repo.deleteMission(id);
    } catch (_) {
      await load();
    }
  }
}

final adminMissionsProvider = StateNotifierProvider<AdminMissionsNotifier, AsyncValue<List<AdminMissionDefinition>>>((ref) {
  return AdminMissionsNotifier(ref.watch(adminRepositoryProvider));
});

// ===============================================================
// Forest Seasons — StateNotifier + Optimistic
// ===============================================================

class AdminSeasonsNotifier extends StateNotifier<AsyncValue<List<AdminForestSeason>>> {
  final SupabaseAdminRepository _repo;

  AdminSeasonsNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final seasons = await _repo.getForestSeasons();
      state = AsyncValue.data(seasons);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createSeason(AdminForestSeason s) async {
    state.whenData((seasons) {
      state = AsyncValue.data([s, ...seasons.map((se) =>
        se.isActive ? AdminForestSeason(
          id: se.id, name: se.name, seasonType: se.seasonType,
          theme: se.theme, description: se.description,
          startDate: se.startDate,
          endDate: DateTime.now(),
          isActive: false, treeCount: se.treeCount, createdAt: se.createdAt,
        ) : se
      )]);
    });
    try {
      final created = await _repo.createSeason(s);
      state.whenData((seasons) {
        state = AsyncValue.data(
          seasons.map((se) => se.id == s.id ? created : se).toList(),
        );
      });
    } catch (_) {
      await load();
    }
  }

  Future<void> endSeason(String id) async {
    state.whenData((seasons) {
      state = AsyncValue.data(
        seasons.map((s) => s.id == id
          ? AdminForestSeason(
              id: s.id, name: s.name, seasonType: s.seasonType,
              theme: s.theme, description: s.description,
              startDate: s.startDate, endDate: DateTime.now(),
              isActive: false, treeCount: s.treeCount, createdAt: s.createdAt,
            )
          : s).toList(),
      );
    });
    try {
      await _repo.endSeason(id);
    } catch (_) {
      await load();
    }
  }
}

final adminForestSeasonsProvider = StateNotifierProvider<AdminSeasonsNotifier, AsyncValue<List<AdminForestSeason>>>((ref) {
  return AdminSeasonsNotifier(ref.watch(adminRepositoryProvider));
});

// ===============================================================
// Banners — StateNotifier + Optimistic
// ===============================================================

class AdminBannersNotifier extends StateNotifier<AsyncValue<List<AdminBanner>>> {
  final SupabaseAdminRepository _repo;

  AdminBannersNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final banners = await _repo.getBanners();
      state = AsyncValue.data(banners);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createBanner(AdminBanner b) async {
    state.whenData((banners) {
      state = AsyncValue.data([...banners, b]);
    });
    try {
      final created = await _repo.createBanner(b);
      state.whenData((banners) {
        state = AsyncValue.data(
          banners.map((bn) => bn.id == b.id ? created : bn).toList(),
        );
      });
    } catch (_) {
      await load();
    }
  }

  Future<void> updateBanner(AdminBanner b) async {
    state.whenData((banners) {
      state = AsyncValue.data(
        banners.map((bn) => bn.id == b.id ? b : bn).toList(),
      );
    });
    try {
      await _repo.updateBanner(b);
    } catch (_) {
      await load();
    }
  }

  Future<void> deleteBanner(String id) async {
    state.whenData((banners) {
      state = AsyncValue.data(banners.where((b) => b.id != id).toList());
    });
    try {
      await _repo.deleteBanner(id);
    } catch (_) {
      await load();
    }
  }

  void reorder(int oldIndex, int newIndex) {
    state.whenData((banners) {
      final list = [...banners];
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      for (var i = 0; i < list.length; i++) {
        // update sort order
        list[i] = AdminBanner(
          id: list[i].id, title: list[i].title, imageUrl: list[i].imageUrl,
          linkValue: list[i].linkValue, linkType: list[i].linkType,
          sortOrder: i, startDate: list[i].startDate, endDate: list[i].endDate,
          isActive: list[i].isActive, clickCount: list[i].clickCount,
          createdAt: list[i].createdAt,
        );
      }
      state = AsyncValue.data(list);

      // persist order
      _repo.reorderBanners(list.map((e) => e.id).toList()).catchError((_) => load());
    });
  }

  Future<void> toggleBanner(String id, bool active) async {
    state.whenData((banners) {
      state = AsyncValue.data(
        banners.map((b) => b.id == id
          ? AdminBanner(
              id: b.id, title: b.title, imageUrl: b.imageUrl,
              linkValue: b.linkValue, linkType: b.linkType,
              sortOrder: b.sortOrder, startDate: b.startDate, endDate: b.endDate,
              isActive: active, clickCount: b.clickCount, createdAt: b.createdAt,
            )
          : b).toList(),
      );
    });
    try {
      await _repo.toggleBanner(id, active);
    } catch (_) {
      await load();
    }
  }
}

final adminBannersProvider = StateNotifierProvider<AdminBannersNotifier, AsyncValue<List<AdminBanner>>>((ref) {
  return AdminBannersNotifier(ref.watch(adminRepositoryProvider));
});

// ===============================================================
// Audit Log
// ===============================================================

final adminAuditLogProvider = FutureProvider<List<AuditLogEntry>>((ref) async {
  return ref.watch(adminRepositoryProvider).getAuditLog();
});

// ===============================================================
// Chart Providers (캐시된 FutureProvider로 유지 — 1회 로드)
// ===============================================================

final adminWeeklyStepsChartProvider = FutureProvider<AdminChartData>((ref) async {
  return ref.watch(adminRepositoryProvider).getWeeklyStepsChart();
});

final adminDailyUsersChartProvider = FutureProvider<AdminChartData>((ref) async {
  return ref.watch(adminRepositoryProvider).getDailyUsersChart();
});

// ===============================================================
// Realtime Subscriptions
// ===============================================================

/// Realtime 구독을 위한 Provider.
/// 각 화면에서 listen() 하여 실시간 업데이트를 받는다.
final adminRealtimeNoticeProvider = StreamProvider<AdminRealtimeEvent<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).subscribeToTable('admin_notices');
});

final adminRealtimeChallengeProvider = StreamProvider<AdminRealtimeEvent<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).subscribeToTable('challenge_definitions');
});

final adminRealtimeMissionProvider = StreamProvider<AdminRealtimeEvent<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).subscribeToTable('mission_definitions');
});

final adminRealtimeSeasonProvider = StreamProvider<AdminRealtimeEvent<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).subscribeToTable('forest_seasons');
});

final adminRealtimeBannerProvider = StreamProvider<AdminRealtimeEvent<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).subscribeToTable('admin_banners');
});
