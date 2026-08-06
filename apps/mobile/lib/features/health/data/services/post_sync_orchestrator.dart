/// ===============================================================
/// HealthON — Post-Sync Orchestrator
///
/// Health 데이터 동기화 완료 후:
///   1. Forest 성장률 갱신
///   2. Challenge 진행률 갱신
///   3. Mission 완료 체크
///   4. Community Snapshot 생성
///
/// 모든 연쇄 작업을 한 번에 실행
/// ===============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import 'forest_sync_service.dart';
import 'challenge_sync_service.dart';
import 'mission_sync_service.dart';

class PostSyncOrchestrator {
  final SupabaseClient _client;
  late final ForestSyncService _forestSync;
  late final ChallengeSyncService _challengeSync;
  late final MissionSyncService _missionSync;

  PostSyncOrchestrator(this._client) {
    _forestSync = ForestSyncService(_client);
    _challengeSync = ChallengeSyncService(_client);
    _missionSync = MissionSyncService(_client);
  }

  /// Health Sync 완료 후 모든 연동 업데이트 실행
  Future<PostSyncResult> runAll(String userId) async {
    final result = PostSyncResult();

    // 1. Forest
    try {
      await _forestSync.syncForestFromHealth(userId);
      result.forestUpdated = true;
    } catch (e) {
      result.errors.add('Forest: $e');
    }

    // 2. Challenge
    try {
      await _challengeSync.syncChallengeFromHealth(userId);
      result.challengeUpdated = true;
    } catch (e) {
      result.errors.add('Challenge: $e');
    }

    // 3. Mission
    try {
      final completed = await _missionSync.checkAndCompleteMissions(userId);
      result.missionsCompleted = completed;
    } catch (e) {
      result.errors.add('Mission: $e');
    }

    // 4. Community Snapshot (health_daily → 오늘 걸음수/거리/칼로리 snapshot)
    try {
      await _createHealthSnapshot(userId);
      result.snapshotCreated = true;
    } catch (e) {
      result.errors.add('Snapshot: $e');
    }

    return result;
  }

  /// 오늘 건강 데이터를 community_post 용 snapshot JSON으로 저장
  ///
  /// 게시글 작성 시 자동 첨부된다.
  Future<void> _createHealthSnapshot(String userId) async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final daily = await _client
        .from('health_daily')
        .select()
        .eq('user_id', userId)
        .eq('date', todayStr)
        .maybeSingle();

    if (daily == null) return;

    final snapshot = {
      'steps': daily['steps'],
      'distance_km': daily['distance_km'],
      'calories': daily['calories'],
      'exercise_minutes': daily['exercise_minutes'],
      'generated_at': DateTime.now().toUtc().toIso8601String(),
    };

    await _client.from('health_snapshots').upsert({
      'user_id': userId,
      'date': todayStr,
      'snapshot_data': snapshot,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,date');
  }
}

class PostSyncResult {
  bool forestUpdated = false;
  bool challengeUpdated = false;
  int missionsCompleted = 0;
  bool snapshotCreated = false;
  final List<String> errors = [];

  bool get hasErrors => errors.isNotEmpty;
  bool get allSuccess => !hasErrors && forestUpdated && challengeUpdated;
}
