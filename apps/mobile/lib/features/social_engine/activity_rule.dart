import 'activity_models.dart';

/// ===============================================================
/// HealthON — Activity Rule Engine
///
/// 각 ActivityEvent가 Community Feed로 변환될 조건을 정의한다.
/// ===============================================================

class ActivityRule {
  /// 단계 업데이트 최소 기준을 넘었는지
  bool shouldCreateFeed(ActivityEvent event) {
    switch (event.type) {
      case ActivityEventType.dailyStepsUpdated:
        return _meetsStepsThreshold(event.data);
      case ActivityEventType.forestLevelUp:
        return true; // 레벨업은 항상 알림
      case ActivityEventType.challengeCompleted:
        return true;
      case ActivityEventType.challengeProgressMilestone:
        return _meetsMilestone(event.data);
      case ActivityEventType.missionCompleted:
        return true;
      case ActivityEventType.badgeUnlocked:
        return true;
      case ActivityEventType.rankingChanged:
        return _isTopRank(event.data);
      case ActivityEventType.familyChallengeCompleted:
        return true;
      case ActivityEventType.reactionAdded:
        return _meetsReactionThreshold(event.data);
      default:
        return false;
    }
  }

  /// 일정 걸음 이상일 때만 Feed 생성
  bool _meetsStepsThreshold(Map<String, dynamic> data) {
    final steps = (data['steps'] ?? 0) as int;
    // 3000보 이상일 때만 피드 생성 (너무 잦은 업데이트 방지)
    return steps >= 3000 && steps % 1000 == 0;
  }

  /// Challenge 이정표 (25%, 50%, 75%, 100%)
  bool _meetsMilestone(Map<String, dynamic> data) {
    final progress = (data['progress'] ?? 0).toDouble();
    return progress >= 0.25 && (progress * 100) % 25 == 0;
  }

  /// Top 3 랭킹만 Feed 생성
  bool _isTopRank(Map<String, dynamic> data) {
    final rank = (data['newRank'] ?? 999) as int;
    return rank <= 3;
  }

  /// 반응 5개 이상일 때만 Feed 알림
  bool _meetsReactionThreshold(Map<String, dynamic> data) {
    final count = (data['totalReactions'] ?? 0) as int;
    return count >= 5;
  }

  /// Feed 타입 결정
  FeedType determineFeedType(ActivityEvent event) {
    switch (event.type) {
      case ActivityEventType.dailyStepsUpdated:
        return FeedType.walking;
      case ActivityEventType.forestLevelUp:
        return FeedType.forest;
      case ActivityEventType.challengeCompleted:
      case ActivityEventType.challengeProgressMilestone:
        return FeedType.challenge;
      case ActivityEventType.missionCompleted:
        return FeedType.normal;
      case ActivityEventType.badgeUnlocked:
        return FeedType.badge;
      case ActivityEventType.rankingChanged:
        return FeedType.ranking;
      case ActivityEventType.familyChallengeCompleted:
        return FeedType.family;
      case ActivityEventType.postCreated:
        return FeedType.normal;
      default:
        return FeedType.system;
    }
  }

  /// Feed 제목 생성
  String generateFeedTitle(ActivityEvent event, String userName) {
    switch (event.type) {
      case ActivityEventType.dailyStepsUpdated:
        final steps = (event.data['steps'] ?? 0) as int;
        return '$userName님이 오늘 ${_formatSteps(steps)}보를 걸었습니다 🚶';
      case ActivityEventType.forestLevelUp:
        final level = (event.data['newLevel'] ?? 1) as int;
        final treeName = event.data['treeName'] as String? ?? '새싹';
        return '$userName님의 Forest가 Lv.$level $treeName(으)로 성장했습니다 🌳';
      case ActivityEventType.challengeCompleted:
        final name = event.data['challengeName'] as String? ?? 'Challenge';
        return '$userName님이 $name을 완료했습니다 🏆';
      case ActivityEventType.challengeProgressMilestone:
        final progress = ((event.data['progress'] ?? 0).toDouble() * 100).round();
        final name = event.data['challengeName'] as String? ?? 'Challenge';
        return '$userName님이 $name ${progress}%를 달성했습니다 🔥';
      case ActivityEventType.missionCompleted:
        final title = event.data['missionTitle'] as String? ?? 'Mission';
        return '$userName님이 "$title" 미션을 완료했습니다 ✅';
      case ActivityEventType.badgeUnlocked:
        final badge = event.data['badgeTitle'] as String? ?? 'Badge';
        return '$userName님이 "$badge" 뱃지를 획득했습니다 🏅';
      case ActivityEventType.rankingChanged:
        final rank = (event.data['newRank'] ?? 0) as int;
        final scope = event.data['scope'] as String? ?? '주간';
        return '$userName님이 ${scope}랭킹 ${rank}위에 올랐습니다 🎯';
      case ActivityEventType.familyChallengeCompleted:
        return '$userName님의 가족이 Challenge를 완료했습니다 👨‍👩‍👧‍👦';
      case ActivityEventType.friendAdded:
        final friend = event.data['friendName'] as String? ?? '친구';
        return '$userName님이 $friend님과 친구가 되었습니다 🤝';
      default:
        return '$userName님의 새로운 활동';
    }
  }

  /// Feed 본문 생성
  String? generateFeedBody(ActivityEvent event) {
    switch (event.type) {
      case ActivityEventType.dailyStepsUpdated:
        final dist = (event.data['distanceKm'] ?? 0).toDouble();
        final cal = (event.data['calories'] ?? 0).toDouble();
        return '거리: ${dist.toStringAsFixed(1)}km · 칼로리: ${cal.round()}kcal · 오늘도 화이팅!';
      case ActivityEventType.forestLevelUp:
        final old = event.data['oldLevel'] ?? 1;
        final now = event.data['newLevel'] ?? 1;
        return 'Lv.$old → Lv.$now 레벨업! 더 큰 나무로 성장했어요 🌲';
      case ActivityEventType.challengeCompleted:
        final total = (event.data['totalKm'] ?? 0).toDouble();
        return '총 ${total.toStringAsFixed(1)}km를 걸었습니다. 축하합니다! 🎉';
      default:
        return null;
    }
  }

  String _formatSteps(int steps) {
    return steps.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
