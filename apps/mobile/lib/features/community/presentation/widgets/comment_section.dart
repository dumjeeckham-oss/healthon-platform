import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/community_comment.dart';
import '../providers/community_provider.dart';

/// ===============================================================
///
/// HealthON CommentSection
///
/// community_detail_screen 의 댓글 UI 를 대체하는
/// 재사용 가능한 독립 위젯입니다.
///
/// 사용 예시:
///
/// ```dart
/// CommentSection(postId: post.id)
/// ```
///
/// ===============================================================

class CommentSection extends ConsumerStatefulWidget {
  final String postId;

  const CommentSection({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  // ===============================================================
  // Composer State
  // ===============================================================

  final TextEditingController _composerCtrl = TextEditingController();
  final FocusNode _composerFocus = FocusNode();

  String? _replyToId;
  String? _replyToUserName;

  bool _composerHasText = false;

  // ===============================================================
  // Lifecycle
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _composerCtrl.addListener(() {
      final bool hasText = _composerCtrl.text.trim().isNotEmpty;
      if (_composerHasText != hasText) {
        setState(() {
          _composerHasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _composerCtrl.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  // ===============================================================
  // Reply
  // ===============================================================

  void _startReply({required String commentId, required String userName}) {
    setState(() {
      _replyToId = commentId;
      _replyToUserName = userName;
    });
    _composerFocus.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToUserName = null;
    });
  }

  // ===============================================================
  // Submit
  // ===============================================================

  void _submitComment() {
    final String text = _composerCtrl.text.trim();

    if (text.isEmpty) return;

    final CommunityComment comment = CommunityComment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      postId: widget.postId,
      userId: 'current_user',
      parentId: _replyToId,
      content: text,
      createdAt: DateTime.now(),
    );

    ref.read(addCommentProvider(comment).future);

    _composerCtrl.clear();
    _composerFocus.unfocus();

    setState(() {
      _replyToId = null;
      _replyToUserName = null;
      _composerHasText = false;
    });
  }

  // ===============================================================
  // Build
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CommunityComment>> asyncComments =
        ref.watch(communityCommentsProvider(widget.postId));

    return Column(
      children: [
        // =========================================================
        // Header
        // =========================================================

        const _CommentHeader(),

        const SizedBox(height: 8),

        // =========================================================
        // List
        // =========================================================

        _CommentList(
          asyncComments: asyncComments,
          onReply: _startReply,
        ),

        const SizedBox(height: 8),

        // =========================================================
        // Composer
        // =========================================================

        _CommentComposer(
          controller: _composerCtrl,
          focusNode: _composerFocus,
          hasText: _composerHasText,
          replyToUserName: _replyToUserName,
          onCancelReply: _cancelReply,
          onSubmit: _submitComment,
          onChanged: () {
            // listener handles setState
          },
        ),
      ],
    );
  }
}

// ===================================================================
// Header
// ===================================================================

class _CommentHeader extends StatelessWidget {
  const _CommentHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Text(
            '💬',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(width: 6),
          Text(
            '댓글',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// Comment List
// ===================================================================

class _CommentList extends StatelessWidget {
  final AsyncValue<List<CommunityComment>> asyncComments;
  final void Function({
    required String commentId,
    required String userName,
  }) onReply;

  const _CommentList({
    required this.asyncComments,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return asyncComments.when(
      // -------------------------------------------------------------
      // Loading
      // -------------------------------------------------------------

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

      // -------------------------------------------------------------
      // Error
      // -------------------------------------------------------------

      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '댓글을 불러올 수 없습니다',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
          ),
        ),
      ),

      // -------------------------------------------------------------
      // Data
      // -------------------------------------------------------------

      data: (comments) {
        if (comments.isEmpty) {
          return const _CommentEmpty();
        }

        final List<CommunityComment> roots =
            comments.where((c) => c.isRoot).toList();

        return Column(
          children: roots.map((root) {
            final List<CommunityComment> replies = comments
                .where((c) => c.parentId == root.id)
                .toList();

            return Column(
              children: [
                _CommentTile(
                  comment: root,
                  onReply: () => onReply(
                    commentId: root.id,
                    userName: root.userId,
                  ),
                ),

                if (replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 52),
                    child: Column(
                      children: replies.map((r) {
                        return _ReplyTile(
                          comment: r,
                          onReply: () => onReply(
                            commentId: r.id,
                            userName: r.userId,
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
// Empty State
// ===================================================================

class _CommentEmpty extends StatelessWidget {
  const _CommentEmpty();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '💬',
              style: TextStyle(fontSize: 36),
            ),
            SizedBox(height: 10),
            Text(
              '아직 댓글이 없습니다.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF757575),
              ),
            ),
            SizedBox(height: 4),
            Text(
              '첫 댓글을 작성해보세요.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// Comment Tile (Root)
// ===================================================================

class _CommentTile extends StatelessWidget {
  final CommunityComment comment;
  final VoidCallback onReply;

  const _CommentTile({
    required this.comment,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _commentAvatar(size: 32, iconSize: 16),

          const SizedBox(width: 10),

          Expanded(child: _commentBody(comment, isReply: false, onReply: onReply)),

          _heartButton(),
        ],
      ),
    );
  }
}

// ===================================================================
// Reply Tile
// ===================================================================

class _ReplyTile extends StatelessWidget {
  final CommunityComment comment;
  final VoidCallback onReply;

  const _ReplyTile({
    required this.comment,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _commentAvatar(size: 28, iconSize: 14),

          const SizedBox(width: 8),

          Expanded(child: _commentBody(comment, isReply: true, onReply: onReply)),

          _heartButton(size: 14),
        ],
      ),
    );
  }
}

// ===================================================================
// Shared Helpers
// ===================================================================

Widget _commentAvatar({required double size, required double iconSize}) {
  return CircleAvatar(
    radius: size / 2,
    backgroundColor: Colors.green.shade100,
    child: Icon(
      Icons.person,
      size: iconSize,
      color: const Color(0xFF2E7D32),
    ),
  );
}

Widget _commentBody(
  CommunityComment comment, {
  required bool isReply,
  required VoidCallback onReply,
}) {
  return Column(
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
            _timeAgo(comment.createdAt),
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
          Text(
            '좋아요 ${comment.likeCount}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _heartButton({double size = 16}) {
  return GestureDetector(
    onTap: () {},
    child: Icon(
      Icons.favorite_border,
      size: size,
      color: Colors.grey.shade400,
    ),
  );
}

// ===================================================================
// Time Ago
// ===================================================================

String _timeAgo(DateTime dt) {
  final Duration d = DateTime.now().difference(dt);

  if (d.inSeconds < 60) return '방금 전';
  if (d.inMinutes < 60) return '${d.inMinutes}분 전';
  if (d.inHours < 24) return '${d.inHours}시간 전';
  if (d.inDays < 7) return '${d.inDays}일 전';
  if (d.inDays < 30) return '${d.inDays ~/ 7}주 전';
  if (d.inDays < 365) return '${d.inDays ~/ 30}개월 전';
  return '${d.inDays ~/ 365}년 전';
}

// ===================================================================
// Reply Banner
// ===================================================================

class _ReplyBanner extends StatelessWidget {
  final String userName;
  final VoidCallback onCancel;

  const _ReplyBanner({
    required this.userName,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '@$userName님에게 답글',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onCancel,
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// Comment Composer
// ===================================================================

class _CommentComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final String? replyToUserName;
  final VoidCallback onCancelReply;
  final VoidCallback onSubmit;
  final VoidCallback onChanged;

  const _CommentComposer({
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.replyToUserName,
    required this.onCancelReply,
    required this.onSubmit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              // --- Reply Banner ---

              if (replyToUserName != null)
                _ReplyBanner(
                  userName: replyToUserName!,
                  onCancel: onCancelReply,
                ),

              // --- TextField + Send ---

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
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
                      onChanged: (_) => onChanged(),
                      onSubmitted: (_) => onSubmit(),
                    ),
                  ),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: onSubmit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: hasText
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
    );
  }
}
