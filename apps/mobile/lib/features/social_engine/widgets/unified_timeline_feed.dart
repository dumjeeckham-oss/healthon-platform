import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../social_provider.dart';
import '../timeline_algorithm.dart';
import 'achievement_cards.dart';

/// ===============================================================
/// HealthON — Unified Timeline Feed (Pageable)
///
/// community_posts + feed_items 혼합 타임라인 + 무한 스크롤
/// ===============================================================

class UnifiedTimelineFeed extends ConsumerStatefulWidget {
  const UnifiedTimelineFeed({super.key});

  @override
  ConsumerState<UnifiedTimelineFeed> createState() => _UnifiedTimelineFeedState();
}

class _UnifiedTimelineFeedState extends ConsumerState<UnifiedTimelineFeed> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _items = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final algorithm = ref.read(timelineAlgorithmProvider);
      final userId = ref.read(socialUserIdProvider);
      final newItems = await algorithm.getTimeline(
        viewerUserId: userId,
        page: _currentPage,
      );

      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        setState(() {
          _items.addAll(newItems);
          _currentPage++;
        });
      }
    } catch (e) {
      debugPrint('Timeline load error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _currentPage = 0;
      _hasMore = true;
      _isLoading = false;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty && !_hasMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '아직 피드가 없습니다.\n걷기를 시작하면 자동으로 생성됩니다!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final item = _items[index];
          final source = item['_source'] as String? ?? 'post';

          if (source == 'feed') {
            return _FeedItemCard(item: item);
          } else {
            return _PostItemCard(item: item);
          }
        },
      ),
    );
  }
}

/// 자동 생성 피드 카드
class _FeedItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _FeedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final type = item['type'] as String? ?? 'normal';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: switch (type) {
        'walking' => WalkMilestoneCard(
            steps: _toInt(item['data']?['steps']),
            distanceKm: _toDouble(item['data']?['distanceKm']),
            calories: _toDouble(item['data']?['calories']),
          ),
        'forest' => ForestAchievementCard(
            level: _toInt(item['data']?['level']),
            treeName: item['data']?['treeName'] as String? ?? '새싹',
            totalSteps: _toInt(item['data']?['totalSteps']),
          ),
        'challenge' => ChallengeAchievementCard(
            challengeName: item['data']?['challengeName'] as String? ?? 'Challenge',
            totalKm: _toDouble(item['data']?['totalKm']),
            progress: _toDouble(item['data']?['progress']),
            completed: item['data']?['completed'] == true,
          ),
        'badge' => BadgeAchievementCard(
            badgeTitle: item['data']?['badgeTitle'] as String? ?? '',
            badgeIcon: item['data']?['badgeIcon'] as String? ?? '🏅',
          ),
        _ => _defaultCard(item),
      },
    );
  }

  Widget _defaultCard(Map<String, dynamic> item) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['actor_name'] as String? ?? '건강ON',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(item['title'] as String? ?? ''),
          ],
        ),
      ),
    );
  }

  int _toInt(dynamic v) => (v ?? 0) is int ? v as int : (v ?? 0).toInt();
  double _toDouble(dynamic v) => (v ?? 0.0).toDouble();
}

/// 사용자 작성 게시글 카드
class _PostItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _PostItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['title'] as String? ?? '';
    final content = item['content'] as String? ?? '';
    final userName = item['profiles']?['name'] as String? ?? '사용자';
    final createdAt = item['created_at'] != null
        ? DateTime.parse(item['created_at'] as String)
        : DateTime.now();
    final likeCount = item['like_count'] as int? ?? 0;
    final commentCount = item['comment_count'] as int? ?? 0;
    final images = item['images'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                  child: Text(
                    userName.isNotEmpty ? userName[0] : '?',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(
                        DateFormat('MM/dd HH:mm').format(createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (title.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
            if (content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                content,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (images.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length.clamp(0, 5),
                  separatorBuilder: (_, __) => const SizedBox(width: 4),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      images[i].toString(),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.favorite_border, size: 18, color: Colors.grey.shade500),
                if (likeCount > 0)
                  Text(' $likeCount', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey.shade500),
                if (commentCount > 0)
                  Text(' $commentCount', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
