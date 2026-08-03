import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/models/community_post.dart';
import '../providers/community_provider.dart';
import '../widgets/comment_section.dart';

// ===============================================================
// Community Detail Screen
// ===============================================================

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
  // Controllers
  // ===============================================================

  final ScrollController _scrollCtrl = ScrollController();
  final PageController _pageCtrl = PageController();

  // ===============================================================
  // Local State
  // ===============================================================

  bool _showFab = false;
  int _currentImage = 0;
  bool _isLiked = false;
  bool _isBookmarked = false;

  // ===============================================================
  // Lifecycle
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  // ===============================================================
  // Scroll — FAB visibility
  // ===============================================================

  void _onScroll() {
    final bool show = _scrollCtrl.hasClients && _scrollCtrl.offset > 400;
    if (show != _showFab) {
      setState(() => _showFab = show);
    }
  }

  // ===============================================================
  // Pull-to-Refresh
  // ===============================================================

  Future<void> _onRefresh() async {
    ref.invalidate(communityPostProvider(widget.postId));
    ref.invalidate(communityCommentsProvider(widget.postId));
    await ref.read(communityPostProvider(widget.postId).future);
  }

  // ===============================================================
  // Helpers
  // ===============================================================

  String _timeAgo(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7}주 전';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30}개월 전';
    return '${diff.inDays ~/ 365}년 전';
  }

  String _categoryLabel(CommunityCategory cat) {
    switch (cat) {
      case CommunityCategory.notice:
        return '공지';
      case CommunityCategory.challenge:
        return '챌린지';
      case CommunityCategory.walking:
        return '걷기';
      case CommunityCategory.forest:
        return 'Forest';
      case CommunityCategory.health:
        return '건강';
      case CommunityCategory.photo:
        return '사진';
      case CommunityCategory.free:
        return '자유';
      case CommunityCategory.question:
        return '질문';
      case CommunityCategory.event:
        return '이벤트';
    }
  }

  Color _categoryColor(CommunityCategory cat) {
    switch (cat) {
      case CommunityCategory.forest:
        return const Color(0xFF2E7D32);
      case CommunityCategory.walking:
        return const Color(0xFFFF9800);
      case CommunityCategory.challenge:
        return const Color(0xFF1565C0);
      case CommunityCategory.health:
        return const Color(0xFFE91E63);
      case CommunityCategory.notice:
        return const Color(0xFFF44336);
      case CommunityCategory.event:
        return const Color(0xFF9C27B0);
      case CommunityCategory.photo:
        return const Color(0xFF00BCD4);
      case CommunityCategory.free:
        return Colors.grey;
      case CommunityCategory.question:
        return const Color(0xFF795548);
    }
  }

  // ===============================================================
  // Menu
  // ===============================================================

  ReportReason? _selectedReportReason;

  void _showReportDialog(CommunityPost post) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('게시글 신고'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ReportReason.values
                .map(
                  (r) => RadioListTile<ReportReason>(
                    title: Text(r.label),
                    value: r,
                    groupValue: _selectedReportReason,
                    onChanged: (v) {
                      setState(() => _selectedReportReason = v);
                    },
                    activeColor: const Color(0xFF2E7D32),
                    contentPadding: EdgeInsets.zero,
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _selectedReportReason = null);
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: _selectedReportReason != null
                  ? () async {
                      Navigator.pop(context);
                      final String currentUserId =
                          Supabase.instance.client.auth.currentUser?.id ??
                              'current_user';
                      try {
                        await ref
                            .read(
                              reportPostProvider(
                                (
                                  reporterId: currentUserId,
                                  postId: post.id,
                                  reason: _selectedReportReason!.name,
                                ),
                              ).future,
                            );
                      } catch (_) {
                        // 실패해도 SnackBar 표시
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('신고가 접수되었습니다'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        setState(() => _selectedReportReason = null);
                      }
                    }
                  : null,
              child: const Text(
                '신고',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(CommunityPost post) {
    final String text = '''HealthON에서 공유된 게시글

"${post.title}"

${post.content.length > 80 ? '${post.content.substring(0, 80)}...' : post.content}

https://healthon.app/post/${post.id}''';

    Share.share(text, subject: post.title);
  }

  void _showMenu(CommunityPost post) {
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
              _menuTile(Icons.edit_outlined, '수정'),
              _menuTile(
                Icons.delete_outline,
                '삭제',
                isRed: true,
                onTap: () async {
                  Navigator.pop(context);
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text('게시글 삭제'),
                      content: const Text('정말 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            '삭제',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              _menuTile(
                Icons.report_outlined,
                '신고',
                isRed: true,
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(post);
                },
              ),
              _menuTile(Icons.block_outlined, '차단'),
              _menuTile(Icons.share_outlined, '공유', onTap: () {
                Navigator.pop(context);
                _sharePost(post);
              }),
              const Divider(),
              _menuTile(Icons.close, '닫기'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(
    IconData icon,
    String label, {
    bool isRed = false,
    VoidCallback? onTap,
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
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  // ===============================================================
  // Build
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CommunityPost> postAsync =
        ref.watch(communityPostProvider(widget.postId));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: postAsync.when(
        loading: () => _buildLoading(),
        error: (Object e, StackTrace? _) => _buildError(e),
        data: (CommunityPost post) => _buildContent(post),
      ),
    );
  }

  // ===============================================================
  // Loading — Skeleton
  // ===============================================================

  Widget _buildLoading() {
    return Scaffold(
      key: const ValueKey('detail_loading'),
      backgroundColor: const Color(0xFFF6F8F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.grey.shade300,
            elevation: 0,
            leading: _backButton(),
            actions: [_moreButtonLoading()],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Colors.grey.shade300),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: double.infinity, height: 24),
                  const SizedBox(height: 8),
                  _SkeletonBox(width: 160, height: 16),
                  const SizedBox(height: 24),
                  _SkeletonBox(width: double.infinity, height: 200),
                  const SizedBox(height: 16),
                  _SkeletonBox(width: double.infinity, height: 120),
                  const SizedBox(height: 16),
                  _SkeletonBox(width: double.infinity, height: 100),
                  const SizedBox(height: 16),
                  _SkeletonBox(width: 140, height: 36),
                  const SizedBox(height: 32),
                  ...List.generate(
                    4,
                    (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SkeletonBox(
                        width: double.infinity,
                        height: 56,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // Error
  // ===============================================================

  Widget _buildError(Object e) {
    return Scaffold(
      key: const ValueKey('detail_error'),
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _backButton(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                '게시글을 불러올 수 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                label: '다시 시도',
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(
                      communityPostProvider(widget.postId),
                    );
                    ref.invalidate(
                      communityCommentsProvider(widget.postId),
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('다시 시도'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // Content — Post body
  // ===============================================================

  Widget _buildContent(CommunityPost post) {
    final bool hasImages = post.images.isNotEmpty;

    return Scaffold(
      key: ValueKey(post.id),
      backgroundColor: const Color(0xFFF6F8F7),

      // ===========================================================
      // Body — Pull-to-Refresh + CustomScrollView
      // ===========================================================

      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF2E7D32),
        backgroundColor: Colors.white,
        displacement: 40,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // =====================================================
            // SliverAppBar + Image Carousel
            // =====================================================

            SliverAppBar(
              expandedHeight: hasImages ? 340 : 200,
              pinned: true,
              backgroundColor: const Color(0xFF2E7D32),
              elevation: 0,
              leading: _backButton(),
              actions: [_moreButton(post)],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // --- Gradient background ---
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

                    // --- Image Carousel ---
                    if (hasImages)
                      GestureDetector(
                        onTap: () {},
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageCtrl,
                              itemCount: post.images.length,
                              onPageChanged: (int i) {
                                setState(() => _currentImage = i);
                              },
                              itemBuilder: (_, int i) {
                                return Hero(
                                  tag: '${post.id}_img_$i',
                                  child: Image.network(
                                    post.images[i],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.green.shade100,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.white54,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // --- Page Indicator ---
                            if (post.images.length > 1)
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Wrap(
                                    spacing: 4,
                                    children: List.generate(
                                      post.images.length,
                                      (int i) {
                                        final bool isActive =
                                            _currentImage == i;
                                        return AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          width: isActive ? 20 : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? Colors.white
                                                : Colors.white54,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // --- No-image placeholder ---
                    if (!hasImages)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🌳',
                              style: TextStyle(
                                fontSize: 56,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _categoryLabel(post.category),
                              style: TextStyle(
                                fontSize: 14,
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

            // =====================================================
            // Content Sliver
            // =====================================================

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // =================================================
                  // Category Chip
                  // =================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _categoryColor(post.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _categoryColor(post.category).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _categoryLabel(post.category),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _categoryColor(post.category),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // Author + Time
                  // =================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.green.shade100,
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF2E7D32),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.userId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =================================================
                  // Title (Hero)
                  // =================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Hero(
                      tag: post.id,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // Content body
                  // =================================================

                  if (post.content.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        post.content,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // =================================================
                  // Forest Snapshot Card
                  // =================================================

                  if (post.forestSnapshot != null)
                    _SnapshotDetailCard(
                      icon: '🌳',
                      title: 'Forest Snapshot',
                      snapshot: post.forestSnapshot!,
                      color: Colors.green,
                    ),

                  // =================================================
                  // Walking Snapshot Card
                  // =================================================

                  if (post.walkingSnapshot != null)
                    _SnapshotDetailCard(
                      icon: '🚶',
                      title: 'Walking Snapshot',
                      snapshot: post.walkingSnapshot!,
                      color: Colors.orange,
                    ),

                  // =================================================
                  // Badge / Challenge Snapshot Card
                  // =================================================

                  if (post.badgeSnapshot != null)
                    _SnapshotDetailCard(
                      icon: '🎯',
                      title: 'Badge Snapshot',
                      snapshot: post.badgeSnapshot!,
                      color: Colors.blue,
                    ),

                  const SizedBox(height: 8),

                  // =================================================
                  // Action Bar
                  // =================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        // --- Like ---
                        Semantics(
                          button: true,
                          label: _isLiked ? '좋아요 취소' : '좋아요',
                          child: IconButton(
                            onPressed: () {
                              setState(() => _isLiked = !_isLiked);
                              ref.read(
                                togglePostLikeProvider(post.id).future,
                              );
                            },
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                              ) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey('like_$_isLiked'),
                                color: _isLiked
                                    ? Colors.red
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${post.likeCount + (_isLiked ? 1 : 0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 6),

                        // --- Comment ---
                        Semantics(
                          button: true,
                          label: '댓글 ${post.commentCount}개',
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.mode_comment_outlined),
                          ),
                        ),
                        Text(
                          '${post.commentCount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 6),

                        // --- Share ---
                        Semantics(
                          button: true,
                          label: '공유',
                          child: IconButton(
                            onPressed: () => _sharePost(post),
                            icon: const Icon(Icons.share_outlined),
                          ),
                        ),

                        const Spacer(),

                        // --- Bookmark ---
                        Semantics(
                          button: true,
                          label: _isBookmarked ? '북마크 취소' : '북마크',
                          child: IconButton(
                            onPressed: () {
                              setState(() => _isBookmarked = !_isBookmarked);
                              ref.read(
                                toggleBookmarkProvider(post.id).future,
                              );
                            },
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                              ) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                _isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                key: ValueKey('bookmark_$_isBookmarked'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // Like count summary
                  // =================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      '좋아요 ${post.likeCount + (_isLiked ? 1 : 0)}개',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // Hashtags
                  // =================================================

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

                  const SizedBox(height: 14),

                  const Divider(indent: 18, endIndent: 18),

                  const SizedBox(height: 6),

                  // =================================================
                  // Comment Section
                  // =================================================

                  CommentSection(postId: post.id),

                  // =================================================
                  // Related Posts
                  // =================================================

                  const SizedBox(height: 8),

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

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 138,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: _relatedMock.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, int i) {
                        final Map<String, String> m = _relatedMock[i];
                        return _RelatedCard(
                          icon: m['icon'] ?? '',
                          title: m['title'] ?? '',
                          subtitle: m['sub'] ?? '',
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
      ),

      // ===========================================================
      // FAB — Scroll to top
      // ===========================================================

      floatingActionButton: AnimatedOpacity(
        opacity: _showFab ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedScale(
          scale: _showFab ? 1.0 : 0.3,
          duration: const Duration(milliseconds: 300),
          child: Semantics(
            button: true,
            label: '맨 위로 이동',
            child: FloatingActionButton.small(
              onPressed: _showFab
                  ? () {
                      _scrollCtrl.animateTo(
                        0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    }
                  : null,
              backgroundColor: const Color(0xFF2E7D32),
              child: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // AppBar buttons
  // ===============================================================

  Widget _backButton() {
    return Semantics(
      button: true,
      label: '뒤로 가기',
      child: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
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
    );
  }

  Widget _moreButtonLoading() {
    return IconButton(
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
      onPressed: null,
    );
  }

  Widget _moreButton(CommunityPost post) {
    return IconButton(
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
      onPressed: () => _showMenu(post),
    );
  }

  // ===============================================================
  // Related Posts Mock
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
}

// ===================================================================
// Snapshot Detail Card
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
                      color: color.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...snapshot.entries
                      .where(
                        (MapEntry<String, dynamic> e) =>
                            e.key != 'icon' && e.key != 'color',
                      )
                      .take(4)
                      .map(
                        (MapEntry<String, dynamic> e) => Padding(
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
// Hash Chip
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

// ===================================================================
// Skeleton Box
// ===================================================================

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBox({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ===================================================================
// Related Post Card
// ===================================================================

class _RelatedCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _RelatedCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
            icon,
            style: const TextStyle(fontSize: 28),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
