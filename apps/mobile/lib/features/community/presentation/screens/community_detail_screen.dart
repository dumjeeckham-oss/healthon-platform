import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/community_post.dart';
import '../../domain/models/community_comment.dart';
import '../providers/community_provider.dart';
import '../widgets/community_post_card.dart';

class CommunityDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const CommunityDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState
    extends ConsumerState<CommunityDetailScreen> {
  // ===============================================================
  // Scroll
  // ===============================================================

  final ScrollController _scrollController = ScrollController();
  final PageController _imagePageController = PageController();

  // ===============================================================
  // Action State
  // ===============================================================

  bool _liked = false;
  bool _bookmarked = false;
  int _currentImageIndex = 0;

  // ===============================================================
  // ⑨ Emoji Reaction
  // ===============================================================

  final Map<String, int> _reactionCounts = {
    '👍': 0,
    '❤️': 0,
    '🔥': 0,
    '👏': 0,
    '😂': 0,
    '😲': 0,
  };

  String? _selectedReactionKey;

  bool _showEmojiPicker = false;

  // ===============================================================
  // Comment Composer
  // ===============================================================

  final TextEditingController _commentController =
      TextEditingController();

  final FocusNode _commentFocusNode = FocusNode();

  String? _replyToId;
  String? _replyToUserName;

  // ===============================================================
  // Related Posts mock
  // ===============================================================

  static const List<Map<String, String>> _relatedMock = [
    {
      'icon': '🌱',
      'title': '새싹이 자랐어요',
      'sub': 'Forest · 2시간 전',
    },
    {
      'icon': '🚶',
      'title': '오늘 10,000보 달성!',
      'sub': 'Walking · 30분 전',
    },
    {
      'icon': '🎯',
      'title': '챌린지 100K 도전중',
      'sub': 'Challenge · 1일 전',
    },
  ];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _imagePageController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Collapse-aware — reserved for SliverAppBar snap
  }

  // ===============================================================
  // Reaction Handler
  // ===============================================================

  void _handleReaction(String key) {
    setState(() {
      if (_selectedReactionKey == key) {
        _selectedReactionKey = null;
        _reactionCounts[key] = (_reactionCounts[key] ?? 1) - 1;
      } else {
        if (_selectedReactionKey != null) {
          _reactionCounts[_selectedReactionKey!] =
              (_reactionCounts[_selectedReactionKey!] ?? 1) - 1;
        }
        _selectedReactionKey = key;
        _reactionCounts[key] = (_reactionCounts[key] ?? 0) + 1;
      }
    });
  }

  // ===============================================================
  // Comment Submit
  // ===============================================================

  void _submitComment() {
    final String text = _commentController.text.trim();

    if (text.isEmpty) return;

    final CommunityComment comment = CommunityComment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      postId: widget.postId,
      userId: 'current_user',
      parentId: _replyToId,
      content: text,
      createdAt: DateTime.now(),
    );

    ref.read(addCommentProvider(comment));

    _commentController.clear();
    _commentFocusNode.unfocus();

    setState(() {
      _replyToId = null;
      _replyToUserName = null;
    });
  }

  void _replyToComment({
    required String commentId,
    required String userName,
  }) {
    setState(() {
      _replyToId = commentId;
      _replyToUserName = userName;
    });

    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToUserName = null;
    });
  }

  // ===============================================================
  // Menu
  // ===============================================================

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _menuTile(Icons.edit_outlined, '수정', () {
                Navigator.pop(context);
              }),
              _menuTile(Icons.delete_outline, '삭제', () {
                Navigator.pop(context);
              }),
              _menuTile(Icons.report_outlined, '신고', () {
                Navigator.pop(context);
              }),
              _menuTile(Icons.block_outlined, '차단', () {
                Navigator.pop(context);
              }),
              _menuTile(Icons.share_outlined, '공유', () {
                Navigator.pop(context);
              }),
              const Divider(),
              _menuTile(Icons.close, '닫기', () {
                Navigator.pop(context);
              }, isDestructive: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.black87,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  // ===============================================================
  // Build
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CommunityPost> asyncPost =
        ref.watch(communityPostProvider(widget.postId));

    return asyncPost.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4CAF50),
          ),
        ),
      ),

      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  '게시글을 불러올 수 없습니다',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  e.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
      ),

      data: (post) => _DetailBody(post: post),
    );
  }
}

// ===================================================================
// Detail Body
// ===================================================================

class _DetailBody extends ConsumerStatefulWidget {
  final CommunityPost post;

  const _DetailBody({required this.post});

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  // ===============================================================
  // State
  // ===============================================================

  final PageController _pageController = PageController();

  int _currentImage = 0;

  bool _liked = false;

  bool _bookmarked = false;

  final TextEditingController _commentCtrl = TextEditingController();

  final FocusNode _commentFocus = FocusNode();

  String? _replyToId;

  String? _replyToUserName;

  String? _selectedReaction;

  final Map<String, int> _reactions = {
    '👍': 3,
    '❤️': 7,
    '🔥': 2,
    '👏': 1,
    '😂': 0,
    '😲': 0,
  };

  bool _showReactionBar = false;

  @override
  void dispose() {
    _pageController.dispose();
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _handleReaction(String key) {
    setState(() {
      if (_selectedReaction == key) {
        _selectedReaction = null;
        _reactions[key] = (_reactions[key] ?? 1) - 1;
      } else {
        if (_selectedReaction != null) {
          _reactions[_selectedReaction!] =
              (_reactions[_selectedReaction!] ?? 1) - 1;
        }
        _selectedReaction = key;
        _reactions[key] = (_reactions[key] ?? 0) + 1;
      }
      _showReactionBar = false;
    });
  }

  void _submitComment() {
    final String text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    final comment = CommunityComment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: 'current_user',
      parentId: _replyToId,
      content: text,
      createdAt: DateTime.now(),
    );

    ref.read(addCommentProvider(comment));
    _commentCtrl.clear();
    _commentFocus.unfocus();

    setState(() {
      _replyToId = null;
      _replyToUserName = null;
    });
  }

  void _replyTo(String id, String name) {
    setState(() {
      _replyToId = id;
      _replyToUserName = name;
    });
    _commentFocus.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToUserName = null;
    });
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return '방금 전';
    if (d.inMinutes < 60) return '${d.inMinutes}분 전';
    if (d.inHours < 24) return '${d.inHours}시간 전';
    if (d.inDays < 7) return '${d.inDays}일 전';
    if (d.inDays < 30) return '${d.inDays ~/ 7}주 전';
    if (d.inDays < 365) return '${d.inDays ~/ 30}개월 전';
    return '${d.inDays ~/ 365}년 전';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),

      // ===========================================================
      // ① SliverAppBar
      // ===========================================================

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            elevation: 0,
            leading: IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _bottomMenuItem(
                              Icons.edit_outlined,
                              '수정',
                            ),
                            _bottomMenuItem(
                              Icons.delete_outline,
                              '삭제',
                              isRed: true,
                            ),
                            _bottomMenuItem(
                              Icons.report_outlined,
                              '신고',
                              isRed: true,
                            ),
                            _bottomMenuItem(
                              Icons.block_outlined,
                              '차단',
                            ),
                            _bottomMenuItem(
                              Icons.share_outlined,
                              '공유',
                            ),
                            const Divider(),
                            _bottomMenuItem(
                              Icons.close,
                              '닫기',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // --- Gradient bg ---

                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1B5E20),
                          Color(0xFF2E7D32),
                          Color(0xFF4CAF50),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // =================================================
                  // ③ Image Carousel (Hero)
                  // =================================================

                  if (post.images.isNotEmpty)
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: post.images.length,
                            onPageChanged: (i) {
                              setState(() => _currentImage = i);
                            },
                            itemBuilder: (_, i) {
                              return Hero(
                                tag: '${post.id}-$i',
                                child: Image.network(
                                  post.images[i],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              );
                            },
                          ),

                          // --- Indicator ---

                          if (post.images.length > 1)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children:
                                    List.generate(post.images.length, (i) {
                                  return AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: _currentImage == i ? 20 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentImage == i
                                          ? Colors.white
                                          : Colors.white54,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // --- No-image placeholder ---

                  if (post.images.isEmpty)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🌳',
                            style: TextStyle(
                              fontSize: 64,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'HealthON Forest',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ===========================================================
          // Content Area
          // ===========================================================

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // =====================================================
                // ② Header
                // =====================================================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF2E7D32),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.userId,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _timeAgo(post.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- Forest Level Badge ---

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🌲', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              'Lv.7',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // =====================================================
                // ③ Title + Body
                // =====================================================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (post.content.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          post.content,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =====================================================
                // ④ Forest Snapshot
                // =====================================================

                if (post.forestSnapshot != null)
                  _SnapshotDetailCard(
                    icon: '🌳',
                    title: 'Forest Snapshot',
                    snapshot: post.forestSnapshot!,
                    color: Colors.green,
                  ),

                // =====================================================
                // ⑤ Walking Snapshot
                // =====================================================

                if (post.walkingSnapshot != null)
                  _SnapshotDetailCard(
                    icon: '🚶',
                    title: 'Walking Snapshot',
                    snapshot: post.walkingSnapshot!,
                    color: Colors.orange,
                  ),

                // =====================================================
                // ⑥ Mission Snapshot
                // =====================================================

                if (post.badgeSnapshot != null)
                  _SnapshotDetailCard(
                    icon: '🎯',
                    title: 'Mission Snapshot',
                    snapshot: post.badgeSnapshot!,
                    color: Colors.blue,
                  ),

                const SizedBox(height: 12),

                // =====================================================
                // ⑧ Action Bar
                // =====================================================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      // --- Like ---

                      IconButton(
                        onPressed: () {
                          setState(() => _liked = !_liked);
                        },
                        icon: Icon(
                          _liked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _liked ? Colors.red : Colors.grey.shade700,
                        ),
                      ),

                      Text(
                        '${post.likeCount + (_liked ? 1 : 0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(width: 10),

                      // --- Comment ---

                      IconButton(
                        onPressed: () => _commentFocus.requestFocus(),
                        icon: const Icon(Icons.mode_comment_outlined),
                      ),

                      Text('${post.commentCount}'),

                      const SizedBox(width: 10),

                      // --- Share ---

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                      ),

                      const Spacer(),

                      // --- Bookmark ---

                      IconButton(
                        onPressed: () {
                          setState(() => _bookmarked = !_bookmarked);
                        },
                        icon: Icon(
                          _bookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                        ),
                      ),
                    ],
                  ),
                ),

                // =====================================================
                // Like count text
                // =====================================================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    '좋아요 ${post.likeCount + (_liked ? 1 : 0)}개',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                // =====================================================
                // ⑨ Emoji Reaction
                // =====================================================

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showReactionBar = !_showReactionBar;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _showReactionBar
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _showReactionBar
                                  ? Colors.green.shade300
                                  : Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('😊', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                _selectedReaction ?? '반응',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedReaction != null
                                      ? Colors.green.shade700
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // --- Reaction chips summary ---

                      ..._reactions.entries
                          .where((e) => e.value > 0)
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: GestureDetector(
                                onTap: () => _handleReaction(e.key),
                                child: Chip(
                                  label: Text(
                                    '${e.key} ${e.value}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _selectedReaction == e.key
                                          ? Colors.green.shade700
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  backgroundColor:
                                      _selectedReaction == e.key
                                          ? Colors.green.shade50
                                          : Colors.grey.shade100,
                                  side: BorderSide(
                                    color: _selectedReaction == e.key
                                        ? Colors.green.shade300
                                        : Colors.grey.shade300,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _showReactionBar
                      ? Container(
                          margin: const EdgeInsets.only(
                            top: 8,
                            left: 16,
                            right: 16,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              '👍', '❤️', '🔥', '👏', '😂', '😲',
                              '🎉', '💪', '🌳', '🏃',
                            ].map((e) {
                              return GestureDetector(
                                onTap: () => _handleReaction(e),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: 42,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _selectedReaction == e
                                        ? Colors.green.shade50
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 14),

                // =====================================================
                // ⑩ Hashtag
                // =====================================================

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _HashChip(label: 'HealthON'),
                      _HashChip(label: 'Forest'),
                      _HashChip(label: 'Walking'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Divider(indent: 18, endIndent: 18),

                const SizedBox(height: 8),

                // =====================================================
                // ⑪ Comment Section
                // =====================================================

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    '댓글',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                _CommentListSection(
                  postId: post.id,
                  onReply: _replyTo,
                ),

                const SizedBox(height: 8),

                // =====================================================
                // ⑫ Related Posts
                // =====================================================

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    '관련 게시글',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final m = _DetailBodyState._relatedMock[i];

                      return Container(
                        width: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['icon'] ?? '',
                              style: const TextStyle(fontSize: 28),
                            ),
                            const Spacer(),
                            Text(
                              m['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              m['sub'] ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),

      // ===============================================================
      // ⑬ Bottom Composer
      // ===============================================================

      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Reply indicator ---

                if (_replyToId != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '@${_replyToUserName ?? ''}님에게 답글',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _cancelReply,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                // --- Input row ---

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        focusNode: _commentFocus,
                        cursorColor: const Color(0xFF2E7D32),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '댓글을 입력하세요...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F8F7),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),

                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap: _submitComment,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _commentCtrl.text.trim().isNotEmpty
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomMenuItem(
    IconData icon,
    String label, {
    bool isRed = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isRed ? Colors.red : Colors.black87,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: isRed ? Colors.red : Colors.black87,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

// ===================================================================
// ④⑤⑥ Snapshot Detail Card
// ===================================================================

class _SnapshotDetailCard extends StatelessWidget {
  final String icon;
  final String title;
  final Map<String, dynamic> snapshot;
  final Color color;

  const _SnapshotDetailCard({
    required this.icon,
    required this.title,
    required this.snapshot,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: color.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...snapshot.entries
                      .where((e) => e.key != 'icon' && e.key != 'color')
                      .take(4)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// ⑪ Comment List Section
// ===================================================================

class _CommentListSection extends ConsumerWidget {
  final String postId;
  final void Function(String commentId, String userName) onReply;

  const _CommentListSection({
    required this.postId,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CommunityComment>> asyncComments =
        ref.watch(communityCommentsProvider(postId));

    return asyncComments.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
      ),

      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '댓글을 불러올 수 없습니다',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ),

      data: (comments) {
        if (comments.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '아직 댓글이 없어요\n첫 번째 댓글을 작성해보세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          );
        }

        final roots = comments.where((c) => c.isRoot).toList();

        return Column(
          children: roots.map((root) {
            final replies = comments
                .where((c) => c.parentId == root.id)
                .toList();

            return Column(
              children: [
                _CommentTile(
                  comment: root,
                  onReply: () => onReply(
                    root.id,
                    root.userId,
                  ),
                ),

                // --- Replies ---

                if (replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 52),
                    child: Column(
                      children: replies.map((r) {
                        return _CommentTile(
                          comment: r,
                          isReply: true,
                          onReply: () => onReply(
                            r.id,
                            r.userId,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

// ===================================================================
// Comment Tile
// ===================================================================

class _CommentTile extends StatelessWidget {
  final CommunityComment comment;
  final bool isReply;
  final VoidCallback onReply;

  const _CommentTile({
    required this.comment,
    this.isReply = false,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 14 : 16,
            backgroundColor: Colors.green.shade100,
            child: Icon(
              Icons.person,
              size: isReply ? 14 : 16,
              color: const Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userId,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isReply ? 12 : 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _commentTimeAgo(comment.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: isReply ? 13 : 14,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        '답글 달기',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        '좋아요 ${comment.likeCount}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.favorite_border,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  String _commentTimeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return '방금 전';
    if (d.inMinutes < 60) return '${d.inMinutes}분 전';
    if (d.inHours < 24) return '${d.inHours}시간 전';
    if (d.inDays < 7) return '${d.inDays}일 전';
    if (d.inDays < 30) return '${d.inDays ~/ 7}주 전';
    return '${d.inDays ~/ 30}개월 전';
  }
}

// ===================================================================
// ⑩ Hash Chip
// ===================================================================

class _HashChip extends StatelessWidget {
  final String label;

  const _HashChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      '#$label',
      style: TextStyle(
        color: Colors.green.shade700,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}
