import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/community_comment.dart';
import '../providers/comment_like_provider.dart';
import 'comment_utils.dart';

/// ===============================================================
///
/// HealthON Comment Widgets
///
/// comment_section.dart 에서 사용하는 개별 위젯들입니다.
///
/// ===============================================================

// ===================================================================
// Comment Header
// ===================================================================

class CommentHeader extends StatelessWidget {
  const CommentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Text('💬', style: TextStyle(fontSize: 16)),
          SizedBox(width: 6),
          Text(
            '댓글',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// Comment Empty State
// ===================================================================

class CommentEmpty extends StatefulWidget {
  const CommentEmpty({super.key});

  @override
  State<CommentEmpty> createState() => _CommentEmptyState();
}

class _CommentEmptyState extends State<CommentEmpty>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacity = CurvedAnimation(parent: _ac, curve: Curves.easeIn);

    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _opacity,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('💬', style: TextStyle(fontSize: 36)),
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
        ),
      ),
    );
  }
}

// ===================================================================
// Comment Tile (Root + Reply unified via Dismissible)
// ===================================================================

class CommentTile extends ConsumerWidget {
  final CommunityComment comment;
  final bool isReply;
  final VoidCallback onReply;

  const CommentTile({
    super.key,
    required this.comment,
    this.isReply = false,
    required this.onReply,
  });

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('댓글 삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('댓글이 삭제되었습니다'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeNotifier = ref.watch(commentLikeProvider);
    final bool liked = likeNotifier.isLiked(comment.id);

    return Semantics(
      label: '${comment.userId}님의 댓글: ${comment.content}',
      button: false,
      child: Dismissible(
        key: ValueKey('comment_${comment.id}'),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            final bool? confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text('댓글 삭제'),
                content: const Text('정말 삭제하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('삭제', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            return confirmed ?? false;
          }
          // Swipe right → reply
          onReply();
          return false;
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          color: const Color(0xFF2E7D32).withOpacity(0.08),
          child: const Icon(Icons.reply, color: Color(0xFF2E7D32), size: 20),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red.withOpacity(0.08),
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: isReply ? 4 : 6,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commentAvatar(size: isReply ? 28 : 32, iconSize: isReply ? 14 : 16),

              const SizedBox(width: 10),

              Expanded(
                child: commentBody(
                  comment.userId,
                  comment.createdAt,
                  comment.content,
                  comment.likeCount,
                  isReply,
                  onReply,
                  () => ref.read(commentLikeProvider.notifier).toggle(comment.id),
                  liked,
                ),
              ),

              // --- Heart ---

              commentHeartButton(
                liked: liked,
                size: isReply ? 14 : 16,
                onTap: () => ref.read(commentLikeProvider.notifier).toggle(comment.id),
              ),

              // --- More ---

              GestureDetector(
                onTap: () => showCommentMoreMenu(
                  context,
                  onReply: onReply,
                  onEdit: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('댓글 수정 — 준비 중입니다'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  onDelete: () => _showDeleteDialog(context, ref),
                  onReport: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('신고가 접수되었습니다'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  onBlock: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text('사용자 차단'),
                      content: const Text('이 사용자를 차단하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('차단', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Icon(
                    Icons.more_horiz,
                    size: isReply ? 14 : 16,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// Reply Banner
// ===================================================================

class ReplyBanner extends StatelessWidget {
  final String userName;
  final VoidCallback onCancel;

  const ReplyBanner({
    super.key,
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
            child: Icon(Icons.close, size: 16, color: Colors.green.shade600),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// Comment Composer
// ===================================================================

class CommentComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final String? replyToUserName;
  final VoidCallback onCancelReply;
  final VoidCallback onSubmit;
  final VoidCallback onChanged;

  const CommentComposer({
    super.key,
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
              if (replyToUserName != null)
                ReplyBanner(
                  userName: replyToUserName!,
                  onCancel: onCancelReply,
                ),

              Row(
                children: [
                  // --- Emoji ---

                  Semantics(
                    label: '이모지',
                    child: GestureDetector(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text('😊', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // --- TextField ---

                  Expanded(
                    child: Semantics(
                      label: '댓글 입력',
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        cursorColor: commentPrimaryColor,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '댓글을 입력하세요...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: replyToUserName != null
                              ? Colors.green.shade50
                              : commentBgColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: replyToUserName != null
                                ? const BorderSide(
                                    color: Color(0xFF2E7D32),
                                    width: 1.2,
                                  )
                                : BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: replyToUserName != null
                                ? const BorderSide(
                                    color: Color(0xFF2E7D32),
                                    width: 1.2,
                                  )
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: replyToUserName != null
                                ? const BorderSide(
                                    color: Color(0xFF2E7D32),
                                    width: 1.5,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => onChanged(),
                        onSubmitted: (_) => onSubmit(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // --- Image / GIF (TODO) ---

                  Semantics(
                    label: '사진 첨부',
                    child: GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.image_outlined,
                        size: 22,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // --- Send ---

                  Semantics(
                    label: '전송',
                    child: GestureDetector(
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
