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

/// ===============================================================
/// Time Ago — 개선된 버전
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
/// Comment Avatar — 공통 Circle Avatar
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
/// Heart Button — 좋아요 상태 반영
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
/// Comment Body — 닉네임 + 시간 + 본문 + 답글/좋아요
/// ===============================================================

Widget commentBody(
  String userId,
  DateTime createdAt,
  String content,
  int likeCount,
  bool isReply,
  VoidCallback onReply,
  VoidCallback onLikeToggle,
  bool liked,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            userId,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isReply ? 12 : 13,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            commentTimeAgo(createdAt),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),

      const SizedBox(height: 2),

      Text(
        content,
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
            onTap: onLikeToggle,
            child: Text(
              '좋아요 $likeCount',
              style: TextStyle(
                fontSize: 11,
                color: liked ? Colors.red.shade300 : Colors.grey.shade500,
                fontWeight: liked ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

/// ===============================================================
/// More Menu — 댓글 옵션 BottomSheet
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
