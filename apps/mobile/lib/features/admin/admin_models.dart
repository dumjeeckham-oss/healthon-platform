/// ===============================================================
/// HealthON — Admin Models
///
/// 관리자 CMS 용 모델 정의
/// ===============================================================

// ===============================================================
// Admin Member
// ===============================================================

class AdminMember {
  final String userId;
  final String email;
  final String name;
  final String? nickname;
  final String? phone;
  final bool isAdmin;
  final bool isSuspended;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final int totalSteps;
  final int forestLevel;
  final double challengeProgress;
  final int missionsCompleted;
  final int reportCount;

  const AdminMember({
    required this.userId,
    required this.email,
    required this.name,
    this.nickname,
    this.phone,
    this.isAdmin = false,
    this.isSuspended = false,
    required this.createdAt,
    this.lastLoginAt,
    this.totalSteps = 0,
    this.forestLevel = 1,
    this.challengeProgress = 0,
    this.missionsCompleted = 0,
    this.reportCount = 0,
  });

  factory AdminMember.fromSupabase(Map<String, dynamic> row) {
    return AdminMember(
      userId: row['user_id'] ?? row['id'] ?? '',
      email: row['email'] ?? '',
      name: row['name'] ?? '',
      nickname: row['nickname'],
      phone: row['phone'],
      isAdmin: row['is_admin'] == true,
      isSuspended: row['is_suspended'] == true,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'])
          : DateTime.now(),
      lastLoginAt: row['last_login_at'] != null
          ? DateTime.parse(row['last_login_at'])
          : null,
      totalSteps: row['total_steps'] as int? ?? 0,
      forestLevel: row['tree_level'] as int? ?? 1,
      challengeProgress: (row['progress'] as num?)?.toDouble() ?? 0,
      missionsCompleted: row['missions_completed'] as int? ?? 0,
      reportCount: row['report_count'] as int? ?? 0,
    );
  }
}

// ===============================================================
// Admin Notice
// ===============================================================

class AdminNotice {
  final String id;
  final String title;
  final String content;
  final String category; // notice, corporate_news, event, education
  final bool isPinned;
  final bool isPublished;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final List<String> images;
  final List<String> attachments;
  final bool pushSent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminNotice({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'notice',
    this.isPinned = false,
    this.isPublished = false,
    this.scheduledAt,
    this.publishedAt,
    this.images = const [],
    this.attachments = const [],
    this.pushSent = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminNotice.fromSupabase(Map<String, dynamic> row) {
    return AdminNotice(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      content: row['content'] ?? '',
      category: row['category'] ?? 'notice',
      isPinned: row['is_pinned'] == true,
      isPublished: row['is_published'] == true,
      scheduledAt: row['scheduled_at'] != null
          ? DateTime.parse(row['scheduled_at'])
          : null,
      publishedAt: row['published_at'] != null
          ? DateTime.parse(row['published_at'])
          : null,
      images: row['images'] != null
          ? List<String>.from(row['images'])
          : [],
      attachments: row['attachments'] != null
          ? List<String>.from(row['attachments'])
          : [],
      pushSent: row['push_sent'] == true,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'])
          : DateTime.now(),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabase() => {
        if (id.isNotEmpty) 'id': id,
        'title': title,
        'content': content,
        'category': category,
        'is_pinned': isPinned,
        'is_published': isPublished,
        'scheduled_at': scheduledAt?.toUtc().toIso8601String(),
        'published_at': publishedAt?.toUtc().toIso8601String(),
        'images': images,
        'attachments': attachments,
        'push_sent': pushSent,
      };

  AdminNotice copyWith({
    String? title,
    String? content,
    String? category,
    bool? isPinned,
    bool? isPublished,
    DateTime? scheduledAt,
    List<String>? images,
    List<String>? attachments,
    bool? pushSent,
  }) =>
      AdminNotice(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        category: category ?? this.category,
        isPinned: isPinned ?? this.isPinned,
        isPublished: isPublished ?? this.isPublished,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        publishedAt: publishedAt,
        images: images ?? this.images,
        attachments: attachments ?? this.attachments,
        pushSent: pushSent ?? this.pushSent,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

// ===============================================================
// Admin Report
// ===============================================================

enum ReportStatus { pending, reviewed, deleted, hidden, warned, suspended }

class AdminReport {
  final String id;
  final String reporterId;
  final String reporterName;
  final String targetType; // post or comment
  final String targetId;
  final String? targetContent;
  final String reason;
  final String? detail;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const AdminReport({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.targetType,
    required this.targetId,
    this.targetContent,
    required this.reason,
    this.detail,
    this.status = ReportStatus.pending,
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
      reason: row['reason'] ?? '',
      detail: row['detail'],
      status: _parseStatus(row['status']),
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'])
          : DateTime.now(),
      resolvedAt: row['resolved_at'] != null
          ? DateTime.parse(row['resolved_at'])
          : null,
    );
  }

  static ReportStatus _parseStatus(dynamic s) {
    switch (s) {
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
// Admin Challenge Definition
// ===============================================================

class AdminChallengeDefinition {
  final String id;
  final String title;
  final String description;
  final int targetSteps;
  final double targetDistanceKm;
  final String reward;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  const AdminChallengeDefinition({
    required this.id,
    required this.title,
    required this.description,
    this.targetSteps = 100000,
    this.targetDistanceKm = 100,
    this.reward = '',
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory AdminChallengeDefinition.fromSupabase(Map<String, dynamic> row) {
    return AdminChallengeDefinition(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      description: row['description'] ?? '',
      targetSteps: row['target_steps'] as int? ?? 100000,
      targetDistanceKm: (row['target_distance_km'] as num?)?.toDouble() ?? 100,
      reward: row['reward'] ?? '',
      imageUrl: row['image_url'],
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: DateTime.parse(row['end_date'] as String),
      isActive: row['is_active'] == true,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }
}

// ===============================================================
// Admin Mission Definition
// ===============================================================

enum MissionPeriod { daily, weekly, monthly }

class AdminMissionDefinition {
  final String id;
  final String title;
  final String description;
  final MissionPeriod period;
  final int targetSteps;
  final double targetDistanceKm;
  final String rewardType;
  final int rewardValue;
  final bool isActive;
  final DateTime createdAt;

  const AdminMissionDefinition({
    required this.id,
    required this.title,
    required this.description,
    this.period = MissionPeriod.daily,
    this.targetSteps = 5000,
    this.targetDistanceKm = 3.5,
    this.rewardType = 'point',
    this.rewardValue = 10,
    this.isActive = true,
    required this.createdAt,
  });

  factory AdminMissionDefinition.fromSupabase(Map<String, dynamic> row) {
    return AdminMissionDefinition(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      description: row['description'] ?? '',
      period: _parsePeriod(row['period']),
      targetSteps: row['target_steps'] as int? ?? 5000,
      targetDistanceKm: (row['target_distance_km'] as num?)?.toDouble() ?? 3.5,
      rewardType: row['reward_type'] ?? 'point',
      rewardValue: row['reward_value'] as int? ?? 10,
      isActive: row['is_active'] == true,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }

  static MissionPeriod _parsePeriod(dynamic p) {
    switch (p) {
      case 'weekly': return MissionPeriod.weekly;
      case 'monthly': return MissionPeriod.monthly;
      default: return MissionPeriod.daily;
    }
  }
}

// ===============================================================
// Admin Forest Season
// ===============================================================

class AdminForestSeason {
  final String id;
  final String name;
  final String treeType;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  const AdminForestSeason({
    required this.id,
    required this.name,
    required this.treeType,
    required this.description,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory AdminForestSeason.fromSupabase(Map<String, dynamic> row) {
    return AdminForestSeason(
      id: row['id'] ?? '',
      name: row['name'] ?? '',
      treeType: row['tree_type'] ?? '기본',
      description: row['description'] ?? '',
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: row['end_date'] != null ? DateTime.parse(row['end_date']) : null,
      isActive: row['is_active'] == true,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }
}

// ===============================================================
// Admin Banner
// ===============================================================

class AdminBanner {
  final String id;
  final String imageUrl;
  final String? linkUrl;
  final int sortOrder;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  const AdminBanner({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
    this.sortOrder = 0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory AdminBanner.fromSupabase(Map<String, dynamic> row) {
    return AdminBanner(
      id: row['id'] ?? '',
      imageUrl: row['image_url'] ?? '',
      linkUrl: row['link_url'],
      sortOrder: row['sort_order'] as int? ?? 0,
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: DateTime.parse(row['end_date'] as String),
      isActive: row['is_active'] == true,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : DateTime.now(),
    );
  }
}

// ===============================================================
// Admin Dashboard Stats
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
  final double challengeAvgProgress;
  final double missionAvgRate;

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
    this.challengeAvgProgress = 0,
    this.missionAvgRate = 0,
  });
}

class AdminChartData {
  final List<String> labels;
  final List<double> values;

  const AdminChartData({required this.labels, required this.values});
}

// ===============================================================
// Corporate News (법인소식)
// ===============================================================

class CorporateNews {
  final String id;
  final String title;
  final String content;
  final String category; // event, education, training, notice, volunteer
  final String? authorName;
  final bool isPublished;
  final bool isPinned;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final List<String> images;
  final List<String> attachments;
  final bool autoFeed; // 자동 Community Feed 등록 여부
  final DateTime createdAt;
  final DateTime updatedAt;

  const CorporateNews({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'notice',
    this.authorName,
    this.isPublished = false,
    this.isPinned = false,
    this.scheduledAt,
    this.publishedAt,
    this.images = const [],
    this.attachments = const [],
    this.autoFeed = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CorporateNews.fromSupabase(Map<String, dynamic> row) {
    return CorporateNews(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      content: row['content'] ?? '',
      category: row['category'] ?? 'notice',
      authorName: row['author_name'],
      isPublished: row['is_published'] == true,
      isPinned: row['is_pinned'] == true,
      scheduledAt: row['scheduled_at'] != null
          ? DateTime.parse(row['scheduled_at'])
          : null,
      publishedAt: row['published_at'] != null
          ? DateTime.parse(row['published_at'])
          : null,
      images: row['images'] != null
          ? List<String>.from(row['images'])
          : [],
      attachments: row['attachments'] != null
          ? List<String>.from(row['attachments'])
          : [],
      autoFeed: row['auto_feed'] == true,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'])
          : DateTime.now(),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabase() => {
        if (id.isNotEmpty) 'id': id,
        'title': title,
        'content': content,
        'category': category,
        'author_name': authorName,
        'is_published': isPublished,
        'is_pinned': isPinned,
        'scheduled_at': scheduledAt?.toUtc().toIso8601String(),
        'published_at': publishedAt?.toUtc().toIso8601String(),
        'images': images,
        'attachments': attachments,
        'auto_feed': autoFeed,
      };

  CorporateNews copyWith({
    String? title,
    String? content,
    String? category,
    String? authorName,
    bool? isPublished,
    bool? isPinned,
    DateTime? scheduledAt,
    List<String>? images,
    List<String>? attachments,
    bool? autoFeed,
  }) =>
      CorporateNews(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        category: category ?? this.category,
        authorName: authorName ?? this.authorName,
        isPublished: isPublished ?? this.isPublished,
        isPinned: isPinned ?? this.isPinned,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        publishedAt: publishedAt,
        images: images ?? this.images,
        attachments: attachments ?? this.attachments,
        autoFeed: autoFeed ?? this.autoFeed,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

// ===============================================================
// Analytics Models
// ===============================================================

class AnalyticsOverview {
  final int dau;
  final int wau;
  final int mau;
  final double retentionD1;
  final double retentionD7;
  final double retentionD30;
  final int totalForestLevels;
  final double avgForestLevel;
  final int activeChallenges;
  final int completedChallenges;
  final double challengeCompletionRate;
  final int activeMissions;
  final int completedMissions;
  final double missionCompletionRate;
  final int totalPosts;
  final int totalComments;
  final int totalUsers;

  const AnalyticsOverview({
    this.dau = 0,
    this.wau = 0,
    this.mau = 0,
    this.retentionD1 = 0,
    this.retentionD7 = 0,
    this.retentionD30 = 0,
    this.totalForestLevels = 0,
    this.avgForestLevel = 1,
    this.activeChallenges = 0,
    this.completedChallenges = 0,
    this.challengeCompletionRate = 0,
    this.activeMissions = 0,
    this.completedMissions = 0,
    this.missionCompletionRate = 0,
    this.totalPosts = 0,
    this.totalComments = 0,
    this.totalUsers = 0,
  });
}

class AnalyticsChartPoint {
  final String label;
  final double value;

  const AnalyticsChartPoint({required this.label, required this.value});
}
