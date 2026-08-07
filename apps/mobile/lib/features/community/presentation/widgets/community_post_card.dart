import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/models/community_post.dart';
import '../providers/community_provider.dart';

class CommunityPostCard extends ConsumerStatefulWidget {
  final CommunityPost post;

  const CommunityPostCard({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<CommunityPostCard> createState() =>
      _CommunityPostCardState();
}

class _CommunityPostCardState
    extends ConsumerState<CommunityPostCard> {
  late final PageController _pageController;

  int currentImage = 0;

  bool liked = false;

  bool bookmarked = false;

  //----------------------------------------------------
  // ③ Emoji Reaction State
  //----------------------------------------------------
  final Map<String, int> _reactionCounts = {
    '👍': 0,
    '❤️': 0,
    '🔥': 0,
    '👏': 0,
    '😂': 0,
    '😲': 0,
  };

  String? _selectedReactionKey;

  //----------------------------------------------------
  // ① Forest Badge State
  //----------------------------------------------------
  bool _badgesExpanded = false;

  //----------------------------------------------------
  // ② Challenge Ribbon (mock — 모델 확장 시 교체)
  //----------------------------------------------------
  static const List<Map<String, String>> _challengeRibbons = [
    {'icon': '🎯', 'title': '100K Challenge'},
    {'icon': '🔥', 'title': '10일 연속걷기'},
    {'icon': '🏆', 'title': '주간랭킹'},
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() => liked = !liked);
    ref.read(togglePostLikeProvider(widget.post.id).future);
  }

  void _toggleBookmark() {
    setState(() => bookmarked = !bookmarked);
    ref.read(toggleBookmarkProvider(widget.post.id).future);
  }

  void _sharePost() {
    final CommunityPost post = widget.post;
    final String text = '''HealthON에서 공유된 게시글

"${post.title}"

${post.content.length > 80 ? '${post.content.substring(0, 80)}...' : post.content}

https://healthon.app/post/${post.id}''';

    Share.share(text, subject: post.title);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          //----------------------------------------------------
          // Header
          //----------------------------------------------------

          Padding(
            padding:
                const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  child: Icon(
                    Icons.person,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _timeAgo(
                          post.createdAt,
                        ),
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    post.category.name,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: "report",
                      child: Text("신고"),
                    ),
                    const PopupMenuItem(
                      value: "share",
                      child: Text("공유"),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'share') {
                      _sharePost();
                    } else if (value == 'report') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('신고 기능은 상세 화면에서 이용해주세요'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          //----------------------------------------------------
          // Content
          //----------------------------------------------------

          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Text(
                post.content,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),

          const SizedBox(height: 16),

          //----------------------------------------------------
          // Forest Snapshot
          //----------------------------------------------------

          if (post.forestSnapshot != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Text(
                      "🌳",
                      style: TextStyle(
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Forest",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            post.forestSnapshot
                                .toString(),
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (post.forestSnapshot != null)
            const SizedBox(height: 16),

          //----------------------------------------------------
          // Walking Snapshot
          //----------------------------------------------------

          if (post.walkingSnapshot != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Text(
                      "🚶",
                      style: TextStyle(
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Walking",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            post.walkingSnapshot
                                .toString(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (post.walkingSnapshot != null)
            const SizedBox(height: 16),

          //----------------------------------------------------
          // Image Carousel
          //----------------------------------------------------

          if (post.images.isNotEmpty)
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: post.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentImage = index;
                      });
                    },
                    itemBuilder: (_, index) {
                      return Hero(
                        tag: "${post.id}-$index",
                        child: Image.network(
                          post.images[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),

                  //------------------------------------------------
                  // Page Indicator
                  //------------------------------------------------

                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: List.generate(
                        post.images.length,
                        (index) => AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 250),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                          width: currentImage == index ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentImage == index
                                ? Colors.white
                                : Colors.white54,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (post.images.isNotEmpty)
            const SizedBox(height: 12),

          //----------------------------------------------------
          // Action Buttons
          //----------------------------------------------------

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleLike,
                  icon: Icon(
                    liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        liked ? Colors.red : Colors.grey.shade700,
                  ),
                ),
                Text(
                  "${post.likeCount + (liked ? 1 : 0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mode_comment_outlined,
                  ),
                ),
                Text(
                  "${post.commentCount}",
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _sharePost,
                  icon: const Icon(
                    Icons.share_outlined,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _toggleBookmark,
                  icon: Icon(
                    bookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          //----------------------------------------------------
          // Like Text
          //----------------------------------------------------

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "좋아요 ${post.likeCount + (liked ? 1 : 0)}개",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          //----------------------------------------------------
          // ① Forest Badge
          //----------------------------------------------------

          if (post.badgeSnapshot != null)
            _ForestBadgeSection(
              badgeSnapshot: post.badgeSnapshot!,
              badgesExpanded: _badgesExpanded,
              onToggle: () {
                setState(() {
                  _badgesExpanded = !_badgesExpanded;
                });
              },
            ),

          //----------------------------------------------------
          // ② Challenge Ribbon
          //----------------------------------------------------

          const _ChallengeRibbonSection(
            ribbons: _challengeRibbons,
          ),

          const SizedBox(height: 10),

          //----------------------------------------------------
          // ③ Emoji Reaction
          //----------------------------------------------------

          _EmojiReactionBar(
            reactionCounts: _reactionCounts,
            selectedKey: _selectedReactionKey,
            onReaction: (key) {
              setState(() {
                if (_selectedReactionKey == key) {
                  _selectedReactionKey = null;
                  _reactionCounts[key] =
                      (_reactionCounts[key] ?? 1) - 1;
                } else {
                  if (_selectedReactionKey != null) {
                    _reactionCounts[
                        _selectedReactionKey!] =
                        (_reactionCounts[
                                _selectedReactionKey!] ??
                            1) -
                            1;
                  }
                  _selectedReactionKey = key;
                  _reactionCounts[key] =
                      (_reactionCounts[key] ?? 0) + 1;
                }
              });
            },
          ),

          const SizedBox(height: 8),

          //----------------------------------------------------
          // ④ Footer — Hashtags
          //----------------------------------------------------

          const _HashtagFooter(),

          const SizedBox(height: 18),
        ],
      ),
    );
  }

  // ===========================================================
  // _timeAgo
  // ===========================================================

  String _timeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) return "방금 전";

    if (diff.inMinutes < 60) return "${diff.inMinutes}분 전";

    if (diff.inHours < 24) return "${diff.inHours}시간 전";

    if (diff.inDays < 7) return "${diff.inDays}일 전";

    if (diff.inDays < 30) return "${diff.inDays ~/ 7}주 전";

    if (diff.inDays < 365) return "${diff.inDays ~/ 30}개월 전";

    return "${diff.inDays ~/ 365}년 전";
  }
}

// ===============================================================
// ① Forest Badge Section — Stateless Widget
// ===============================================================

class _ForestBadgeSection extends StatelessWidget {
  final Map<String, dynamic> badgeSnapshot;
  final bool badgesExpanded;
  final VoidCallback onToggle;

  const _ForestBadgeSection({
    required this.badgeSnapshot,
    required this.badgesExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> badges =
        _parseBadgeList(badgeSnapshot);

    if (badges.isEmpty) return const SizedBox.shrink();

    final List<Map<String, dynamic>> visibleBadges =
        badgesExpanded ? badges : badges.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Label ---

          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '🏅 Forest Badge',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),

          // --- Badge Chips (Wrap) ---

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(visibleBadges.length, (i) {
                final Map<String, dynamic> b = visibleBadges[i];

                final String icon = b['icon']?.toString() ?? '🏅';
                final String label = b['label']?.toString() ?? 'Badge';
                final String? colorHex = b['color']?.toString();

                final Color chipColor = colorHex != null
                    ? _colorFromHex(colorHex)
                    : Colors.green;

                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: const _AlwaysCompleteAnimation(),
                    curve: Curves.easeIn,
                  ),
                  child: ScaleTransition(
                    scale: const _AlwaysCompleteAnimation(),
                    child: Chip(
                      avatar: Text(
                        icon,
                        style: const TextStyle(fontSize: 14),
                      ),
                      label: Text(
                        label,
                        style: TextStyle(
                          color: chipColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      side: BorderSide(
                        color: chipColor.withOpacity(0.35),
                      ),
                      backgroundColor:
                          chipColor.withOpacity(0.06),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // --- More / Less ---

          if (badges.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: onToggle,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    badgesExpanded ? '접기 ▲' : '더보기 ▼',
                    key: ValueKey<bool>(badgesExpanded),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Parse
  // -------------------------------------------------------------

  static List<Map<String, dynamic>> _parseBadgeList(
    Map<String, dynamic> snapshot,
  ) {
    final dynamic items = snapshot['items'];

    if (items is List) {
      return items
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return [snapshot];
  }

  static Color _colorFromHex(String hex) {
    String h = hex.replaceFirst('#', '');

    if (h.length == 6) h = 'FF$h';

    return Color(int.parse(h, radix: 16));
  }
}

// ===============================================================
// ② Challenge Ribbon Section — Stateless Widget
// ===============================================================

class _ChallengeRibbonSection extends StatelessWidget {
  final List<Map<String, String>> ribbons;

  const _ChallengeRibbonSection({required this.ribbons});

  @override
  Widget build(BuildContext context) {
    if (ribbons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '📋 참여 중인 챌린지',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(ribbons.length, (i) {
                final Map<String, String> r = ribbons[i];

                return Padding(
                  padding: EdgeInsets.only(
                    right: i < ribbons.length - 1 ? 8 : 0,
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: const AlwaysStoppedAnimation(1.0),
                        curve: Interval(
                          0.1 * (i + 1).toDouble(),
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4CAF50),
                            Color(0xFF81C784),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50)
                                .withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${r['icon'] ?? ''}  ${r['title'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ===============================================================
// ③ Emoji Reaction Bar — Stateless Widget
// ===============================================================

class _EmojiReactionBar extends StatelessWidget {
  final Map<String, int> reactionCounts;
  final String? selectedKey;
  final ValueChanged<String> onReaction;

  const _EmojiReactionBar({
    required this.reactionCounts,
    required this.selectedKey,
    required this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: reactionCounts.entries.map((entry) {
            final String key = entry.key;
            final int count = entry.value;
            final bool isSelected = selectedKey == key;

            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => onReaction(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        key,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ===============================================================
// ④ Footer — Hashtag
// ===============================================================

class _HashtagFooter extends StatelessWidget {
  const _HashtagFooter();

  static const List<String> _hashtags = [
    'HealthON',
    'Forest',
    'Walking',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: _hashtags.map((String tag) {
          return GestureDetector(
            onTap: () {
              // TODO — navigate to tag search
            },
            child: Text(
              '#$tag',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ===============================================================
// ⑤ Always-Complete Animation (for static entry transitions)
// ===============================================================

class _AlwaysCompleteAnimation extends Animation<double> {
  const _AlwaysCompleteAnimation();

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void addStatusListener(AnimationStatusListener listener) {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}

  @override
  AnimationStatus get status => AnimationStatus.completed;

  @override
  double get value => 1.0;
}
