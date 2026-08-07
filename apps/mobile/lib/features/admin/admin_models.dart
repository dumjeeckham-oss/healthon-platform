/// ===============================================================
/// HealthON — Admin Models v2 (Production)
///
/// 관리자 CMS 용 완전한 모델 정의
/// StateNotifier + Realtime + Storage + Audit Log 지원
/// ===============================================================

library;

import 'package:flutter/foundation.dart';

// ===============================================================
// Audit Log
// ===============================================================

enum AuditAction {
  created,
  updated,
  deleted,
  published,
  suspended,
  restored,
  grantedAdmin,
  revokedAdmin,
  resolvedReport,
  endedSeason,
  reordered,
  sentPush,
}

class AuditLogEntry {
  final String id;
  final String adminId;
  final String adminName;
  final AuditAction action;
  final String targetType; // notice, challenge, mission, season, banner, member, report
  final String targetId;
  final String? targetName;
  final Map<String, dynamic>? changes;
  final DateTime createdAt;

  const AuditLogEntry({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.targetName,
    this.changes,
    required this.createdAt,
  });

  factory AuditLogEntry.fromSupabase(Map<String, dynamic> row) {
    return AuditLogEntry(
      id: row['id'] ?? '',
      adminId: row['admin_id'] ?? '',
      adminName: row['admin_name'] ?? '알 수 없음',
      action: _parseAction(row['action']),
      targetType: row['target_type'] ?? '',
      targetId: row['target_id'] ?? '',
      targetName: row['target_name'],
      changes: row['changes'] is Map ? Map<String, dynamic>.from(row['changes']) : null,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }

  static AuditAction _parseAction(dynamic a) {
    try {
      return AuditAction.values.firstWhere((e) => e.name == a);
    } catch (_) {
      return AuditAction.updated;
    }
  }

  String get actionLabel => switch (action) {
    AuditAction.created => '생성',
    AuditAction.updated => '수정',
    AuditAction.deleted => '삭제',
    AuditAction.published => '발행',
    AuditAction.suspended => '정지',
    AuditAction.restored => '복구',
    AuditAction.grantedAdmin => '관리자 권한 부여',
    AuditAction.revokedAdmin => '관리자 권한 회수',
    AuditAction.resolvedReport => '신고 처리',
    AuditAction.endedSeason => '시즌 종료',
    AuditAction.reordered => '순서 변경',
    AuditAction.sentPush => '푸시 발송',
  };

  String get targetTypeLabel => switch (targetType) {
    'notice' => '공지사항',
    'challenge' => '챌린지',
    'mission' => '미션',
    'season' => '시즌',
    'banner' => '배너',
    'member' => '회원',
    'report' => '신고',
    _ => targetType,
  };
}

// ===============================================================
// Admin Member (Enhanced)
// ===============================================================

class AdminMember {
  final String userId;
  final String email;
  final String name;
  final String? nickname;
  final String? phone;
  final String? avatarUrl;
  final bool isAdmin;
  final bool isSuspended;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final int totalSteps;
  final double totalDistanceKm;
  final int forestLevel;
  final String? forestTreeType;
  final double challengeProgress;
  final int missionsCompleted;
  final int reportCount;
  final int postCount;
  final int commentCount;
  final String? joinSource;

  const AdminMember({
    required this.userId,
    required this.email,
    required this.name,
    this.nickname,
    this.phone,
    this.avatarUrl,
    this.isAdmin = false,
    this.isSuspended = false,
    required this.createdAt,
    this.lastLoginAt,
    this.totalSteps = 0,
    this.totalDistanceKm = 0,
    this.forestLevel = 1,
    this.forestTreeType,
    this.challengeProgress = 0,
    this.missionsCompleted = 0,
    this.reportCount = 0,
    this.postCount = 0,
    this.commentCount = 0,
    this.joinSource,
  });

  factory AdminMember.fromSupabase(Map<String, dynamic> row) {
    return AdminMember(
      userId: row['user_id'] ?? row['id'] ?? '',
      email: row['email'] ?? '',
      name: row['name'] ?? '',
      nickname: row['nickname'],
      phone: row['phone'],
      avatarUrl: row['avatar_url'],
      isAdmin: row['is_admin'] == true,
      isSuspended: row['is_suspended'] == true,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
      lastLoginAt: row['last_login_at'] != null ? DateTime.parse(row['last_login_at']) : null,
      totalSteps: row['total_steps'] as int? ?? 0,
      totalDistanceKm: (row['total_distance_km'] as num?)?.toDouble() ?? 0,
      forestLevel: row['tree_level'] as int? ?? 1,
      forestTreeType: row['tree_type'] as String?,
      challengeProgress: (row['progress'] as num?)?.toDouble() ?? 0,
      missionsCompleted: row['missions_completed'] as int? ?? 0,
      reportCount: row['report_count'] as int? ?? 0,
      postCount: row['post_count'] as int? ?? 0,
      commentCount: row['comment_count'] as int? ?? 0,
      joinSource: row['join_source'] as String?,
    );
  }
}

enum MemberSortField { createdAt, name, steps, forestLevel, lastLogin, reports }
enum MemberSortOrder { asc, desc }

class MemberFilter {
  final String? search;
  final bool? isAdmin;
  final bool? isSuspended;
  final MemberSortField sortField;
  final MemberSortOrder sortOrder;

  const MemberFilter({
    this.search,
    this.isAdmin,
    this.isSuspended,
    this.sortField = MemberSortField.createdAt,
    this.sortOrder = MemberSortOrder.desc,
  });
}

// ===============================================================
// Admin Notice (Enhanced)
// ===============================================================

class AdminNotice {
  final String id;
  final String title;
  final String content;
  final String category; // notice, corporate_news, event, education, volunteer, training
  final List<String> tags;
  final bool isPinned;
  final bool isPublished;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final List<String> imageUrls;
  final List<String> attachmentUrls;
  final List<String> attachmentNames;
  final bool pushSent;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminNotice({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'notice',
    this.tags = const [],
    this.isPinned = false,
    this.isPublished = false,
    this.scheduledAt,
    this.publishedAt,
    this.imageUrls = const [],
    this.attachmentUrls = const [],
    this.attachmentNames = const [],
    this.pushSent = false,
    this.viewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminNotice.fromSupabase(Map<String, dynamic> row) {
    return AdminNotice(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      content: row['content'] ?? '',
      category: row['category'] ?? 'notice',
      tags: row['tags'] != null ? List<String>.from(row['tags']) : [],
      isPinned: row['is_pinned'] == true,
      isPublished: row['is_published'] == true,
      scheduledAt: row['scheduled_at'] != null ? DateTime.parse(row['scheduled_at']) : null,
      publishedAt: row['published_at'] != null ? DateTime.parse(row['published_at']) : null,
      imageUrls: row['image_urls'] != null ? List<String>.from(row['image_urls']) : [],
      attachmentUrls: row['attachment_urls'] != null ? List<String>.from(row['attachment_urls']) : [],
      attachmentNames: row['attachment_names'] != null ? List<String>.from(row['attachment_names']) : [],
      pushSent: row['push_sent'] == true,
      viewCount: row['view_count'] as int? ?? 0,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
      updatedAt: row['updated_at'] != null ? DateTime.parse(row['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabase() => {
    if (id.isNotEmpty) 'id': id,
    'title': title,
    'content': content,
    'category': category,
    'tags': tags,
    'is_pinned': isPinned,
    'is_published': isPublished,
    'scheduled_at': scheduledAt?.toUtc().toIso8601String(),
    'published_at': publishedAt?.toUtc().toIso8601String(),
    'image_urls': imageUrls,
    'attachment_urls': attachmentUrls,
    'attachment_names': attachmentNames,
    'push_sent': pushSent,
    'view_count': viewCount,
  };

  AdminNotice copyWith({
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    bool? isPinned,
    bool? isPublished,
    DateTime? scheduledAt,
    DateTime? publishedAt,
    List<String>? imageUrls,
    List<String>? attachmentUrls,
    List<String>? attachmentNames,
    bool? pushSent,
    int? viewCount,
  }) =>
      AdminNotice(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        category: category ?? this.category,
        tags: tags ?? this.tags,
        isPinned: isPinned ?? this.isPinned,
        isPublished: isPublished ?? this.isPublished,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        publishedAt: publishedAt ?? this.publishedAt,
        imageUrls: imageUrls ?? this.imageUrls,
        attachmentUrls: attachmentUrls ?? this.attachmentUrls,
        attachmentNames: attachmentNames ?? this.attachmentNames,
        pushSent: pushSent ?? this.pushSent,
        viewCount: viewCount ?? this.viewCount,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

// ===============================================================
// Admin Report (Enhanced)
// ===============================================================

enum ReportStatus { pending, reviewed, deleted, hidden, warned, suspended }

class AdminReport {
  final String id;
  final String reporterId;
  final String reporterName;
  final String targetType; // post, comment
  final String targetId;
  final String? targetContent;
  final String? targetAuthorId;
  final String? targetAuthorName;
  final String reason;
  final String? detail;
  final ReportStatus status;
  final String? resolvedAction;
  final String? resolvedBy;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const AdminReport({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.targetType,
    required this.targetId,
    this.targetContent,
    this.targetAuthorId,
    this.targetAuthorName,
    required this.reason,
    this.detail,
    this.status = ReportStatus.pending,
    this.resolvedAction,
    this.resolvedBy,
    required this.createdAt,
    this.resolvedAt,
  });

  factory AdminReport.fromSupabase(Map<String, dynamic> row) {
    return AdminReport(
      id: row['id'] ?? '',
      reporterId: row['reporter_id'] ?? '',
      reporterName: row['reporter_name'] ?? '알 수 없음',
      targetType: row['target_type'] ?? 'post',
      targetId: row['target_id'] ?? '',
      targetContent: row['target_content'],
      targetAuthorId: row['target_author_id'],
      targetAuthorName: row['target_author_name'],
      reason: row['reason'] ?? '',
      detail: row['detail'],
      status: _parseStatus(row['status']),
      resolvedAction: row['resolved_action'],
      resolvedBy: row['resolved_by'],
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
      resolvedAt: row['resolved_at'] != null ? DateTime.parse(row['resolved_at']) : null,
    );
  }

  static ReportStatus _parseStatus(dynamic s) {
    switch (s?.toString()) {
      case 'reviewed': return ReportStatus.reviewed;
      case 'deleted': return ReportStatus.deleted;
      case 'hidden': return ReportStatus.hidden;
      case 'warned': return ReportStatus.warned;
      case 'suspended': return ReportStatus.suspended;
      default: return ReportStatus.pending;
    }
  }

  String get statusLabel => switch (status) {
    ReportStatus.pending => '대기',
    ReportStatus.reviewed => '검토완료',
    ReportStatus.deleted => '삭제됨',
    ReportStatus.hidden => '숨김',
    ReportStatus.warned => '경고',
    ReportStatus.suspended => '정지',
  };
}

// ===============================================================
// Admin Challenge Definition (Enhanced)
// ===============================================================

class AdminChallengeDefinition {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final int targetSteps;
  final double targetDistanceKm;
  final String reward;
  final String? badgeName;
  final String? badgeImageUrl;
  final int forestBonus;
  final int participationLimit;
  final bool autoStart;
  final bool autoEnd;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int participantCount;
  final DateTime createdAt;

  const AdminChallengeDefinition({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.targetSteps = 100000,
    this.targetDistanceKm = 100,
    this.reward = '',
    this.badgeName,
    this.badgeImageUrl,
    this.forestBonus = 0,
    this.participationLimit = 0,
    this.autoStart = false,
    this.autoEnd = false,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.participantCount = 0,
    required this.createdAt,
  });

  factory AdminChallengeDefinition.fromSupabase(Map<String, dynamic> row) {
    return AdminChallengeDefinition(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      description: row['description'] ?? '',
      imageUrl: row['image_url'],
      targetSteps: row['target_steps'] as int? ?? 100000,
      targetDistanceKm: (row['target_distance_km'] as num?)?.toDouble() ?? 100,
      reward: row['reward'] ?? '',
      badgeName: row['badge_name'],
      badgeImageUrl: row['badge_image_url'],
      forestBonus: row['forest_bonus'] as int? ?? 0,
      participationLimit: row['participation_limit'] as int? ?? 0,
      autoStart: row['auto_start'] == true,
      autoEnd: row['auto_end'] == true,
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: DateTime.parse(row['end_date'] as String),
      isActive: row['is_active'] == true,
      participantCount: row['participant_count'] as int? ?? 0,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabase() => {
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'target_steps': targetSteps,
    'target_distance_km': targetDistanceKm,
    'reward': reward,
    'badge_name': badgeName,
    'badge_image_url': badgeImageUrl,
    'forest_bonus': forestBonus,
    'participation_limit': participationLimit,
    'auto_start': autoStart,
    'auto_end': autoEnd,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'is_active': isActive,
  };
}

// ===============================================================
// Admin Mission Definition (Enhanced)
// ===============================================================

enum MissionPeriod { daily, weekly, monthly, custom }

class AdminMissionCondition {
  final int minSteps;
  final double minDistanceKm;
  final String? timeOfDay; // HH:MM
  final List<String>? requiredDays; // ['mon','tue',...]
  final String? location;

  const AdminMissionCondition({
    this.minSteps = 0,
    this.minDistanceKm = 0,
    this.timeOfDay,
    this.requiredDays,
    this.location,
  });

  Map<String, dynamic> toJson() => {
    'min_steps': minSteps,
    'min_distance_km': minDistanceKm,
    if (timeOfDay != null) 'time_of_day': timeOfDay,
    if (requiredDays != null) 'required_days': requiredDays,
    if (location != null) 'location': location,
  };

  factory AdminMissionCondition.fromJson(Map<String, dynamic> json) {
    return AdminMissionCondition(
      minSteps: json['min_steps'] as int? ?? 0,
      minDistanceKm: (json['min_distance_km'] as num?)?.toDouble() ?? 0,
      timeOfDay: json['time_of_day'] as String?,
      requiredDays: json['required_days'] != null ? List<String>.from(json['required_days']) : null,
      location: json['location'] as String?,
    );
  }
}

class AdminMissionDefinition {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final MissionPeriod period;
  final int customDays;
  final int targetSteps;
  final double targetDistanceKm;
  final AdminMissionCondition? condition;
  final String rewardType;
  final int rewardValue;
  final bool isRepeatable;
  final bool isActive;
  final int completionCount;
  final DateTime createdAt;

  const AdminMissionDefinition({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.period = MissionPeriod.daily,
    this.customDays = 1,
    this.targetSteps = 5000,
    this.targetDistanceKm = 3.5,
    this.condition,
    this.rewardType = 'point',
    this.rewardValue = 10,
    this.isRepeatable = false,
    this.isActive = true,
    this.completionCount = 0,
    required this.createdAt,
  });

  factory AdminMissionDefinition.fromSupabase(Map<String, dynamic> row) {
    return AdminMissionDefinition(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      description: row['description'] ?? '',
      imageUrl: row['image_url'],
      period: _parsePeriod(row['period']),
      customDays: row['custom_days'] as int? ?? 1,
      targetSteps: row['target_steps'] as int? ?? 5000,
      targetDistanceKm: (row['target_distance_km'] as num?)?.toDouble() ?? 3.5,
      condition: row['condition'] != null ? AdminMissionCondition.fromJson(Map<String, dynamic>.from(row['condition'])) : null,
      rewardType: row['reward_type'] ?? 'point',
      rewardValue: row['reward_value'] as int? ?? 10,
      isRepeatable: row['is_repeatable'] == true,
      isActive: row['is_active'] == true,
      completionCount: row['completion_count'] as int? ?? 0,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }

  static MissionPeriod _parsePeriod(dynamic p) {
    switch (p?.toString()) {
      case 'weekly': return MissionPeriod.weekly;
      case 'monthly': return MissionPeriod.monthly;
      case 'custom': return MissionPeriod.custom;
      default: return MissionPeriod.daily;
    }
  }

  String get periodLabel => switch (period) {
    MissionPeriod.daily => '매일',
    MissionPeriod.weekly => '매주',
    MissionPeriod.monthly => '매월',
    MissionPeriod.custom => '$customDays일',
  };
}

// ===============================================================
// Admin Forest Season (Enhanced)
// ===============================================================

enum ForestSeasonType { spring, summer, autumn, winter }

class ForestSeasonTheme {
  final String treeType;
  final String primaryColor; // hex
  final String backgroundColor; // hex
  final String effect; // snow, blossom, leaf, none
  final String? backgroundImageUrl;

  const ForestSeasonTheme({
    this.treeType = '기본',
    this.primaryColor = '#2E7D32',
    this.backgroundColor = '#E8F5E9',
    this.effect = 'none',
    this.backgroundImageUrl,
  });

  Map<String, dynamic> toJson() => {
    'tree_type': treeType,
    'primary_color': primaryColor,
    'background_color': backgroundColor,
    'effect': effect,
    if (backgroundImageUrl != null) 'background_image_url': backgroundImageUrl,
  };

  factory ForestSeasonTheme.fromJson(Map<String, dynamic> json) {
    return ForestSeasonTheme(
      treeType: json['tree_type'] ?? '기본',
      primaryColor: json['primary_color'] ?? '#2E7D32',
      backgroundColor: json['background_color'] ?? '#E8F5E9',
      effect: json['effect'] ?? 'none',
      backgroundImageUrl: json['background_image_url'],
    );
  }

  static const defaultSpring = ForestSeasonTheme(
    treeType: '벚꽃나무',
    primaryColor: '#FFB7C5',
    backgroundColor: '#FFF0F5',
    effect: 'blossom',
  );

  static const defaultSummer = ForestSeasonTheme(
    treeType: '소나무',
    primaryColor: '#2E7D32',
    backgroundColor: '#E8F5E9',
    effect: 'none',
  );

  static const defaultAutumn = ForestSeasonTheme(
    treeType: '단풍나무',
    primaryColor: '#D84315',
    backgroundColor: '#FFF3E0',
    effect: 'leaf',
  );

  static const defaultWinter = ForestSeasonTheme(
    treeType: '겨울나무',
    primaryColor: '#90CAF9',
    backgroundColor: '#E3F2FD',
    effect: 'snow',
  );

  static ForestSeasonTheme defaultFor(ForestSeasonType season) => switch (season) {
    ForestSeasonType.spring => defaultSpring,
    ForestSeasonType.summer => defaultSummer,
    ForestSeasonType.autumn => defaultAutumn,
    ForestSeasonType.winter => defaultWinter,
  };

  static ForestSeasonTheme from(ForestSeasonType season, String treeType) {
    final base = defaultFor(season);
    return ForestSeasonTheme(
      treeType: treeType.isNotEmpty ? treeType : base.treeType,
      primaryColor: base.primaryColor,
      backgroundColor: base.backgroundColor,
      effect: base.effect,
      backgroundImageUrl: base.backgroundImageUrl,
    );
  }
}

class AdminForestSeason {
  final String id;
  final String name;
  final ForestSeasonType seasonType;
  final ForestSeasonTheme theme;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final int treeCount;
  final DateTime createdAt;

  const AdminForestSeason({
    required this.id,
    required this.name,
    required this.seasonType,
    required this.theme,
    required this.description,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.treeCount = 0,
    required this.createdAt,
  });

  factory AdminForestSeason.fromSupabase(Map<String, dynamic> row) {
    return AdminForestSeason(
      id: row['id'] ?? '',
      name: row['name'] ?? '',
      seasonType: _parseSeasonType(row['season_type']),
      theme: row['theme'] != null ? ForestSeasonTheme.fromJson(Map<String, dynamic>.from(row['theme'])) : ForestSeasonTheme.defaultFor(_parseSeasonType(row['season_type'])),
      description: row['description'] ?? '',
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: row['end_date'] != null ? DateTime.parse(row['end_date']) : null,
      isActive: row['is_active'] == true,
      treeCount: row['tree_count'] as int? ?? 0,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }

  static ForestSeasonType _parseSeasonType(dynamic s) {
    switch (s?.toString()) {
      case 'summer': return ForestSeasonType.summer;
      case 'autumn': return ForestSeasonType.autumn;
      case 'winter': return ForestSeasonType.winter;
      default: return ForestSeasonType.spring;
    }
  }

  String get seasonTypeLabel => switch (seasonType) {
    ForestSeasonType.spring => '봄',
    ForestSeasonType.summer => '여름',
    ForestSeasonType.autumn => '가을',
    ForestSeasonType.winter => '겨울',
  };

  Map<String, dynamic> toSupabase() => {
    'name': name,
    'season_type': seasonType.name,
    'theme': theme.toJson(),
    'description': description,
    'start_date': startDate.toIso8601String(),
    'is_active': isActive,
  };
}

// ===============================================================
// Admin Banner (Enhanced)
// ===============================================================

enum BannerLinkType { externalUrl, internalRoute, none }

class AdminBanner {
  final String id;
  final String title;
  final String imageUrl;
  final String? linkValue;
  final BannerLinkType linkType;
  final int sortOrder;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int clickCount;
  final DateTime createdAt;

  const AdminBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkValue,
    this.linkType = BannerLinkType.none,
    this.sortOrder = 0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.clickCount = 0,
    required this.createdAt,
  });

  factory AdminBanner.fromSupabase(Map<String, dynamic> row) {
    return AdminBanner(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      imageUrl: row['image_url'] ?? '',
      linkValue: row['link_value'],
      linkType: _parseLinkType(row['link_type']),
      sortOrder: row['sort_order'] as int? ?? 0,
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: DateTime.parse(row['end_date'] as String),
      isActive: row['is_active'] == true,
      clickCount: row['click_count'] as int? ?? 0,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }

  static BannerLinkType _parseLinkType(dynamic t) {
    switch (t?.toString()) {
      case 'external_url': return BannerLinkType.externalUrl;
      case 'internal_route': return BannerLinkType.internalRoute;
      default: return BannerLinkType.none;
    }
  }
}

// ===============================================================
// Dashboard Stats (Enhanced)
// ===============================================================

class AdminDashboardStats {
  final int todaySignups;
  final int todayLogins;
  final int todaySteps;
  final int todayForestGrowth;
  final int todayChallengeCompletions;
  final int todayMissionCompletions;
  final int todayPosts;
  final int todayComments;
  final int totalUsers;
  final int activeUsers;
  final int suspendedUsers;
  final int totalChallenges;
  final int activeChallenges;
  final int totalSeasons;
  final int pendingReports;
  final double challengeAvgProgress;
  final double missionAvgRate;
  final double weeklyUserGrowthRate;
  final double weeklyStepsGrowthRate;

  const AdminDashboardStats({
    this.todaySignups = 0,
    this.todayLogins = 0,
    this.todaySteps = 0,
    this.todayForestGrowth = 0,
    this.todayChallengeCompletions = 0,
    this.todayMissionCompletions = 0,
    this.todayPosts = 0,
    this.todayComments = 0,
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.suspendedUsers = 0,
    this.totalChallenges = 0,
    this.activeChallenges = 0,
    this.totalSeasons = 0,
    this.pendingReports = 0,
    this.challengeAvgProgress = 0,
    this.missionAvgRate = 0,
    this.weeklyUserGrowthRate = 0,
    this.weeklyStepsGrowthRate = 0,
  });
}

class AdminChartData {
  final List<String> labels;
  final List<double> values;
  final String? yLabel;

  const AdminChartData({required this.labels, required this.values, this.yLabel});
}

// ===============================================================
// Realtime Change Event
// ===============================================================

@immutable
class AdminRealtimeEvent<T> {
  final String eventType; // INSERT, UPDATE, DELETE
  final String table;
  final T? oldRecord;
  final T? newRecord;

  const AdminRealtimeEvent({
    required this.eventType,
    required this.table,
    this.oldRecord,
    this.newRecord,
  });
}

// ===============================================================
// Corporate News (admin_news_screen 용)
// ===============================================================

@immutable
class CorporateNews {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final List<String>? images;
  final List<String>? attachments;
  final String? category;
  final bool isPublished;
  final bool isPinned;
  final bool autoFeed;
  final String? authorName;
  final DateTime? scheduledAt;
  final DateTime? updatedAt;
  final DateTime createdAt;

  const CorporateNews({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.images,
    this.attachments,
    this.category,
    this.isPublished = false,
    this.isPinned = false,
    this.autoFeed = false,
    this.authorName,
    this.scheduledAt,
    this.updatedAt,
    required this.createdAt,
  });

  factory CorporateNews.fromSupabase(Map<String, dynamic> row) => CorporateNews(
    id: row['id'] ?? '',
    title: row['title'] ?? '',
    content: row['content'] ?? '',
    imageUrl: row['image_url'] as String?,
    images: row['images'] != null ? List<String>.from(row['images']) : null,
    attachments: row['attachments'] != null ? List<String>.from(row['attachments']) : null,
    category: row['category'] as String?,
    isPublished: row['is_published'] == true,
    isPinned: row['is_pinned'] == true,
    autoFeed: row['auto_feed'] == true,
    authorName: row['author_name'] as String?,
    scheduledAt: row['scheduled_at'] != null ? DateTime.parse(row['scheduled_at']) : null,
    updatedAt: row['updated_at'] != null ? DateTime.parse(row['updated_at']) : null,
    createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
  );

  Map<String, dynamic> toSupabase() => {
    'title': title,
    'content': content,
    'image_url': imageUrl,
    'images': images,
    'attachments': attachments,
    'category': category,
    'is_published': isPublished,
    'is_pinned': isPinned,
    'auto_feed': autoFeed,
    'author_name': authorName,
    'scheduled_at': scheduledAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  CorporateNews copyWith({
    String? title,
    String? content,
    String? imageUrl,
    List<String>? images,
    List<String>? attachments,
    String? category,
    bool? isPublished,
    bool? isPinned,
    bool? autoFeed,
    String? authorName,
    DateTime? scheduledAt,
    DateTime? updatedAt,
  }) {
    return CorporateNews(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      attachments: attachments ?? this.attachments,
      category: category ?? this.category,
      isPublished: isPublished ?? this.isPublished,
      isPinned: isPinned ?? this.isPinned,
      autoFeed: autoFeed ?? this.autoFeed,
      authorName: authorName ?? this.authorName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt,
    );
  }
}
