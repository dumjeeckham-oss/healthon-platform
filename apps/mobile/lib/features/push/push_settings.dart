/// HealthON Push Settings Model

library;

class PushSettings {
  final String userId;
  final bool pushEnabled;
  final bool noticePush;
  final bool challengePush;
  final bool missionPush;
  final bool forestPush;
  final bool communityPush;
  final bool rewardPush;
  final bool reportPush;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;

  const PushSettings({
    required this.userId,
    this.pushEnabled = true,
    this.noticePush = true,
    this.challengePush = true,
    this.missionPush = true,
    this.forestPush = true,
    this.communityPush = true,
    this.rewardPush = true,
    this.reportPush = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
  });

  factory PushSettings.defaults({required String userId}) => PushSettings(userId: userId);

  factory PushSettings.fromSupabase(Map<String, dynamic> row) => PushSettings(
    userId: row['user_id'] ?? '',
    pushEnabled: row['push_enabled'] ?? true,
    noticePush: row['notice_push'] ?? true,
    challengePush: row['challenge_push'] ?? true,
    missionPush: row['mission_push'] ?? true,
    forestPush: row['forest_push'] ?? true,
    communityPush: row['community_push'] ?? true,
    rewardPush: row['reward_push'] ?? true,
    reportPush: row['report_push'] ?? true,
    quietHoursEnabled: row['quiet_hours_enabled'] ?? false,
    quietHoursStart: row['quiet_hours_start'] ?? '22:00',
    quietHoursEnd: row['quiet_hours_end'] ?? '08:00',
  );

  Map<String, dynamic> toSupabase() => {
    'user_id': userId,
    'push_enabled': pushEnabled,
    'notice_push': noticePush,
    'challenge_push': challengePush,
    'mission_push': missionPush,
    'forest_push': forestPush,
    'community_push': communityPush,
    'reward_push': rewardPush,
    'report_push': reportPush,
    'quiet_hours_enabled': quietHoursEnabled,
    'quiet_hours_start': quietHoursStart,
    'quiet_hours_end': quietHoursEnd,
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  };

  bool isCategoryEnabled(String category) => switch (category) {
    'notice' => noticePush,
    'challenge' => challengePush,
    'mission' => missionPush,
    'forest' => forestPush,
    'community' => communityPush,
    'reward' => rewardPush,
    'report' => reportPush,
    _ => true,
  };

  PushSettings copyWith({
    bool? pushEnabled, bool? noticePush, bool? challengePush,
    bool? missionPush, bool? forestPush, bool? communityPush,
    bool? rewardPush, bool? reportPush, bool? quietHoursEnabled,
    String? quietHoursStart, String? quietHoursEnd,
  }) => PushSettings(
    userId: userId,
    pushEnabled: pushEnabled ?? this.pushEnabled,
    noticePush: noticePush ?? this.noticePush,
    challengePush: challengePush ?? this.challengePush,
    missionPush: missionPush ?? this.missionPush,
    forestPush: forestPush ?? this.forestPush,
    communityPush: communityPush ?? this.communityPush,
    rewardPush: rewardPush ?? this.rewardPush,
    reportPush: reportPush ?? this.reportPush,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    quietHoursStart: quietHoursStart ?? this.quietHoursStart,
    quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
  );

  PushSettings copyWithRaw(Map<String, dynamic> overrides) => PushSettings(
    userId: userId,
    pushEnabled: overrides['push_enabled'] as bool? ?? pushEnabled,
    noticePush: overrides['notice_push'] as bool? ?? noticePush,
    challengePush: overrides['challenge_push'] as bool? ?? challengePush,
    missionPush: overrides['mission_push'] as bool? ?? missionPush,
    forestPush: overrides['forest_push'] as bool? ?? forestPush,
    communityPush: overrides['community_push'] as bool? ?? communityPush,
    rewardPush: overrides['reward_push'] as bool? ?? rewardPush,
    reportPush: overrides['report_push'] as bool? ?? reportPush,
    quietHoursEnabled: overrides['quiet_hours_enabled'] as bool? ?? quietHoursEnabled,
    quietHoursStart: overrides['quiet_hours_start'] as String? ?? quietHoursStart,
    quietHoursEnd: overrides['quiet_hours_end'] as String? ?? quietHoursEnd,
  );
}
