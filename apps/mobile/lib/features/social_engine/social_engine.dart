/// HealthON — Social Engine
///
/// 활동 이벤트 발생 → 자동 피드 생성 → 푸시 알림 → 통합 타임라인
///
/// 사용법:
///   import 'package:healthon/features/social_engine/social_engine.dart';
///
/// 주요 컴포넌트:
///   - ActivityEngine: 이벤트 발생기
///   - ActivityDispatcher: pending 이벤트 처리기
///   - FeedGenerator: ActivityEvent → CommunityPost 변환
///   - NotificationEngine: 알림 관리
///   - TimelineAlgorithm: 통합 타임라인 정렬
///   - AchievementCard: Forest/Challenge/Badge 자동 카드 위젯

library;

export 'activity_models.dart';
export 'activity_rule.dart';
export 'activity_engine.dart';
export 'activity_dispatcher.dart';
export 'feed_generator.dart';
export 'notification_engine.dart';
export 'timeline_algorithm.dart';
export 'ai_recommendation.dart';
export 'social_provider.dart' hide notificationEngineProvider, unreadNotificationCountProvider, recentNotificationsProvider;
export 'social_graph_provider.dart';
export 'notification_provider.dart';
export 'widgets/achievement_cards.dart';
export 'widgets/notification_badge.dart';
export 'widgets/notification_list.dart';
export 'widgets/unified_timeline_feed.dart';
export 'widgets/widgets.dart';
