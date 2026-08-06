import 'package:supabase_flutter/supabase_flutter.dart';

/// ===============================================================
/// HealthON — Timeline Algorithm
///
/// community_posts + feed_items 혼합 정렬 알고리즘
/// - 자동 생성 피드 (걷기/forest/challenge/ranking) + 사용자 작성 게시글
/// - 우선순위 점수 기반 정렬
/// ===============================================================

class TimelineAlgorithm {
  TimelineAlgorithm(this._client);

  final SupabaseClient _client;

  /// 개인화 점수 계산
  double _scoreItem(Map<String, dynamic> post, {String? viewerUserId}) {
    double score = 0;

    final createdAt = DateTime.parse(post['created_at'] as String);
    final ageHours = DateTime.now().difference(createdAt).inHours;

    // 1. 최신성 (최근일수록 높게)
    score += 100 / (ageHours + 1);

    // 2. 인기도 (좋아요 + 댓글)
    final likeCount = (post['like_count'] ?? 0) as int;
    final commentCount = (post['comment_count'] ?? 0) as int;
    score += likeCount * 2 + commentCount * 3;

    // 3. 내 게시글 가중치
    if (viewerUserId != null && post['user_id'] == viewerUserId) {
      score += 10;
    }

    // 4. 자동 생성 피드 가중치 (type field)
    final feedType = post['feed_type'] as String? ?? '';
    switch (feedType) {
      case 'ranking':
        score += 20; break;
      case 'challenge':
        score += 15; break;
      case 'forest':
        score += 12; break;
      case 'badge':
        score += 18; break;
      case 'walking':
        score += 5; break;
      default:
        break;
    }

    // 5. 공지글 가중치
    if (post['category'] == 'notice') {
      score += 30;
    }

    return score;
  }

  /// 통합 타임라인 조회 (community_posts + feed_items 혼합)
  Future<List<Map<String, dynamic>>> getTimeline({
    String? viewerUserId,
    int limit = 50,
    int page = 0,
  }) async {
    // 1. community_posts (사용자 게시글)
    final posts = await _client
        .from('community_posts')
        .select()
        .gt('created_at', _cutoff().toIso8601String())
        .order('created_at', ascending: false)
        .limit(limit * 2);

    // 2. feed_items (자동 생성 피드)
    final feeds = await _client
        .from('feed_items')
        .select()
        .gt('created_at', _cutoff().toIso8601String())
        .order('created_at', ascending: false)
        .limit(limit * 2);

    // 3. 하나의 리스트로 통합
    final List<Map<String, dynamic>> allItems = [];

    for (final p in posts as List) {
      final row = p as Map<String, dynamic>;
      row['_source'] = 'post';
      allItems.add(row);
    }

    for (final f in feeds as List) {
      final row = f as Map<String, dynamic>;
      row['_source'] = 'feed';
      allItems.add(row);
    }

    // 4. 점수 계산 후 정렬
    for (final item in allItems) {
      item['_score'] = _scoreItem(item, viewerUserId: viewerUserId);
    }

    allItems.sort((a, b) {
      final scoreB = (b['_score'] as num).toDouble();
      final scoreA = (a['_score'] as num).toDouble();
      return scoreB.compareTo(scoreA);
    });

    // 5. 페이지네이션
    final start = page * limit;
    if (start >= allItems.length) return [];
    return allItems.sublist(start, (start + limit).clamp(0, allItems.length));
  }

  /// 내가 팔로우한 사용자의 피드만
  Future<List<Map<String, dynamic>>> getFollowingTimeline({
    required String viewerUserId,
    int limit = 50,
  }) async {
    // 팔로우 목록 조회
    final following = await _client
        .from('social_graph')
        .select('to_user_id')
        .eq('from_user_id', viewerUserId)
        .eq('relation_type', 'follow');

    final followingIds = (following as List)
        .map((e) => (e['to_user_id'] as String))
        .toList();

    followingIds.add(viewerUserId); // 내 글도 포함

    if (followingIds.isEmpty) {
      return getTimeline(viewerUserId: viewerUserId, limit: limit);
    }

    // community_posts 필터링
    final posts = await _client
        .from('community_posts')
        .select()
        .inFilter('user_id', followingIds)
        .gt('created_at', _cutoff().toIso8601String())
        .order('created_at', ascending: false)
        .limit(limit * 2);

    final feedItems = await _client
        .from('feed_items')
        .select()
        .inFilter('user_id', followingIds)
        .gt('created_at', _cutoff().toIso8601String())
        .order('created_at', ascending: false)
        .limit(limit * 2);

    final allItems = <Map<String, dynamic>>[];
    for (final p in posts as List) {
      final row = p as Map<String, dynamic>;
      row['_source'] = 'post';
      allItems.add(row);
    }
    for (final f in feedItems as List) {
      final row = f as Map<String, dynamic>;
      row['_source'] = 'feed';
      allItems.add(row);
    }

    for (final item in allItems) {
      item['_score'] = _scoreItem(item, viewerUserId: viewerUserId);
    }

    allItems.sort((a, b) {
      final scoreB = (b['_score'] as num).toDouble();
      final scoreA = (a['_score'] as num).toDouble();
      return scoreB.compareTo(scoreA);
    });

    return allItems.take(limit).toList();
  }

  /// 30일 이상 지난 게시글 제외
  DateTime _cutoff() => DateTime.now().subtract(const Duration(days: 30));
}
