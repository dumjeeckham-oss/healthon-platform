import 'package:flutter/material.dart';

/// ===============================================================
///
/// HealthON Comment Utilities
///
/// 댓글 관련 공통 유틸리티 함수들입니다.
///
/// ===============================================================

const Color commentPrimaryColor = Color(0xFF2E7D32);
const Color commentBgColor = Color(0xFFF6F8F7);

/// Max lines before collapse
const int kCommentMaxLinesCollapsed = 5;

/// ===============================================================
/// Time Ago
/// ===============================================================

String commentTimeAgo(DateTime dt) {
  final Duration d = DateTime.now().difference(dt);

  if (d.inSeconds < 10) return '방금 전';
  if (d.inSeconds < 60) return '${d.inSeconds}초 전';
  if (d.inMinutes < 60) return '${d.inMinutes}분 전';
  if (d.inHours < 24) return '${d.inHours}시간 전';
  if (d.inDays == 1) return '어제';
  if (d.inDays < 7) return '${d.inDays}일 전';
  if (d.inDays < 14) return '1주 전';
  if (d.inDays < 30) return '${d.inDays ~/ 7}주 전';
  if (d.inDays < 60) return '1개월 전';
  if (d.inDays < 365) return '${d.inDays ~/ 30}개월 전';
  return '${d.inDays ~/ 365}년 전';
}

/// ===============================================================
/// Comment Avatar
/// ===============================================================

Widget commentAvatar({required double size, required double iconSize}) {
  return CircleAvatar(
    radius: size / 2,
    backgroundColor: Colors.green.shade100,
    child: Icon(
      Icons.person,
      size: iconSize,
      color: commentPrimaryColor,
    ),
  );
}

/// ===============================================================
/// Heart Button
/// ===============================================================

Widget commentHeartButton({
  required bool liked,
  required VoidCallback onTap,
  double size = 16,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedScale(
      scale: liked ? 1.25 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Icon(
        liked ? Icons.favorite : Icons.favorite_border,
        size: size,
        color: liked ? Colors.red : Colors.grey.shade400,
      ),
    ),
  );
}

/// ===============================================================
/// Comment Body — updated with expand/collapse + edited indicator
/// ===============================================================

Widget commentBody({
  required String userId,
  required DateTime createdAt,
  required String content,
  required int likeCount,
  required bool isReply,
  required VoidCallback onReply,
  required VoidCallback onLikeToggle,
  required bool liked,
  bool isEdited = false,
}) {
  return _CommentBodyCore(
    userId: userId,
    createdAt: createdAt,
    content: content,
    likeCount: likeCount,
    isReply: isReply,
    onReply: onReply,
    onLikeToggle: onLikeToggle,
    liked: liked,
    isEdited: isEdited,
  );
}

class _CommentBodyCore extends StatefulWidget {
  final String userId;
  final DateTime createdAt;
  final String content;
  final int likeCount;
  final bool isReply;
  final VoidCallback onReply;
  final VoidCallback onLikeToggle;
  final bool liked;
  final bool isEdited;

  const _CommentBodyCore({
    required this.userId,
    required this.createdAt,
    required this.content,
    required this.likeCount,
    required this.isReply,
    required this.onReply,
    required this.onLikeToggle,
    required this.liked,
    required this.isEdited,
  });

  @override
  State<_CommentBodyCore> createState() => _CommentBodyCoreState();
}

class _CommentBodyCoreState extends State<_CommentBodyCore> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final int lineCount = '\n'.allMatches(widget.content).length + 1;
    final bool shouldCollapse = !_expanded && lineCount > kCommentMaxLinesCollapsed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Nickname + Time + Edited ---
        Row(
          children: [
            Text(
              widget.userId,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: widget.isReply ? 12 : 13,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              commentTimeAgo(widget.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
            if (widget.isEdited) ...[
              const SizedBox(width: 4),
              Text(
                '(수정됨)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 2),

        // --- Content with expand/collapse ---
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: shouldCollapse
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Text(
            widget.content,
            maxLines: kCommentMaxLinesCollapsed,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: widget.isReply ? 13 : 14,
              height: 1.3,
            ),
          ),
          secondChild: Text(
            widget.content,
            style: TextStyle(
              fontSize: widget.isReply ? 13 : 14,
              height: 1.3,
            ),
          ),
        ),

        // --- "더보기" ---
        if (lineCount > kCommentMaxLinesCollapsed)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _expanded ? '접기' : '...더보기',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        const SizedBox(height: 4),

        // --- Actions ---
        Row(
          children: [
            Semantics(
              button: true,
              label: '답글 달기',
              child: GestureDetector(
                onTap: widget.onReply,
                child: Text(
                  '답글 달기',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Semantics(
              button: true,
              label: widget.liked ? '좋아요 취소' : '좋아요',
              child: GestureDetector(
                onTap: widget.onLikeToggle,
                child: Text(
                  '좋아요 ${widget.likeCount}',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.liked ? Colors.red.shade300 : Colors.grey.shade500,
                    fontWeight: widget.liked ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ===============================================================
/// More Menu
/// ===============================================================

void showCommentMoreMenu(
  BuildContext context, {
  required VoidCallback onReply,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
  required VoidCallback onReport,
  required VoidCallback onBlock,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuTile(context, Icons.reply_outlined, '답글', onReply),
            _menuTile(context, Icons.edit_outlined, '수정', onEdit),
            _menuTile(context, Icons.delete_outline, '삭제', onDelete, isRed: true),
            _menuTile(context, Icons.report_outlined, '신고', onReport, isRed: true),
            _menuTile(context, Icons.block_outlined, '차단', onBlock),
          ],
        ),
      ),
    ),
  );
}

Widget _menuTile(
  BuildContext context,
  IconData icon,
  String label,
  VoidCallback onTap, {
  bool isRed = false,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: isRed ? Colors.red : Colors.black87,
      size: 20,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 14,
        color: isRed ? Colors.red : Colors.black87,
      ),
    ),
    onTap: () {
      Navigator.pop(context);
      onTap();
    },
  );
}
