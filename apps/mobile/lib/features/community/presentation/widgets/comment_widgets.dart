import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/community_comment.dart';
import '../providers/comment_like_provider.dart';
import '../providers/community_provider.dart';
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
// Comment Sort Dropdown
// ===================================================================

class CommentSortDropdown extends ConsumerWidget {
  const CommentSortDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CommentSortType current = ref.watch(commentSortProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Spacer(),
          DropdownButton<CommentSortType>(
            value: current,
            underline: const SizedBox.shrink(),
            isDense: true,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            items: CommentSortType.values.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s.label),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                ref.read(commentSortProvider.notifier).state = v;
              }
            },
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF757575)),
                ),
                SizedBox(height: 4),
                Text(
                  '첫 댓글을 작성해보세요.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
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
  final VoidCallback onDelete;

  CommentTile({
    super.key,
    required this.comment,
    this.isReply = false,
    required this.onReply,
    required this.onDelete,
  });

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController ctrl = TextEditingController(text: comment.content);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('댓글 수정'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          autofocus: true,
          cursorColor: commentPrimaryColor,
          decoration: const InputDecoration(
            hintText: '댓글을 수정하세요...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final String newContent = ctrl.text.trim();
              if (newContent.isEmpty) return;
              Navigator.pop(context);

              final CommunityComment updated = comment.copyWith(
                content: newContent,
                updatedAt: DateTime.now(),
              );

              ref.read(updateCommentProvider(updated).future);
            },
            child: const Text('수정', style: TextStyle(color: Color(0xFF2E7D32))),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              onDelete();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('댓글 신고'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReportReason.values.map((r) {
            return RadioListTile<ReportReason>(
              title: Text(r.label),
              value: r,
              groupValue: _selectedReportReason,
              onChanged: (v) {
                // use dialog setState; for simplicity store in dialog state
              },
              activeColor: const Color(0xFF2E7D32),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final String uid = Supabase.instance.client.auth.currentUser?.id ?? 'current_user';
              ref.read(reportCommentProvider((reporterId: uid, commentId: comment.id, reason: '기타')).future);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('신고가 접수되었습니다'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('신고', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  final ReportReason? _selectedReportReason = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(commentLikeProvider);
    final bool liked = likeState.likedIds.contains(comment.id);

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('댓글 삭제'),
                content: const Text('정말 삭제하시겠습니까?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed == true) onDelete();
            return false;
          }
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
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: isReply ? 4 : 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commentAvatar(size: isReply ? 28 : 32, iconSize: isReply ? 14 : 16),
              const SizedBox(width: 10),
              Expanded(
                child: commentBody(
                  userId: comment.userId,
                  createdAt: comment.createdAt,
                  content: comment.content,
                  likeCount: comment.likeCount,
                  isReply: isReply,
                  onReply: onReply,
                  onLikeToggle: () => ref.read(commentLikeProvider.notifier).toggle(comment.id),
                  liked: liked,
                  isEdited: comment.isEdited,
                  images: comment.images,
                  gifUrl: comment.gifUrl,
                  mentions: comment.mentions,
                ),
              ),

              // --- Heart ---
              commentHeartButton(
                liked: liked,
                size: isReply ? 14 : 16,
                onTap: () => ref.read(commentLikeProvider.notifier).toggle(comment.id),
              ),

              // --- More ---
              Semantics(
                button: true,
                label: '더보기',
                child: GestureDetector(
                  onTap: () => showCommentMoreMenu(
                    context,
                    onReply: onReply,
                    onEdit: () => _showEditDialog(context, ref),
                    onDelete: () => _showDeleteDialog(context, ref),
                    onReport: () => _showReportDialog(context, ref),
                    onBlock: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('사용자 차단'),
                        content: const Text('이 사용자를 차단하시겠습니까?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('차단', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                    commentContent: comment.content,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Icon(Icons.more_horiz, size: isReply ? 14 : 16, color: Colors.grey.shade400),
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

  const ReplyBanner({super.key, required this.userName, required this.onCancel});

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
            style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w600),
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
// Comment Composer (고도화: 이모지 · GIF · 이미지 첨부)
// ===================================================================

class CommentComposer extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final String? replyToUserName;
  final VoidCallback onCancelReply;
  final VoidCallback onSubmit;
  final VoidCallback? onEmojiTap;
  final VoidCallback? onGifTap;
  final VoidCallback? onImageTap;
  final LayerLink? mentionLayerLink;

  /// 첨부 이미지/GIF 미리보기 컨트롤
  final List<String> attachedImages;
  final String? attachedGifUrl;
  final VoidCallback? onClearImages;
  final VoidCallback? onClearGif;

  const CommentComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.replyToUserName,
    required this.onCancelReply,
    required this.onSubmit,
    this.onEmojiTap,
    this.onGifTap,
    this.onImageTap,
    this.mentionLayerLink,
    this.attachedImages = const [],
    this.attachedGifUrl,
    this.onClearImages,
    this.onClearGif,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasAttachments = attachedImages.isNotEmpty || attachedGifUrl != null;

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
              // Reply Banner
              if (replyToUserName != null)
                ReplyBanner(userName: replyToUserName!, onCancel: onCancelReply),

              // Attachment preview
              if (hasAttachments) _AttachmentPreview(
                images: attachedImages,
                gifUrl: attachedGifUrl,
                onClearImages: onClearImages ?? () {},
                onClearGif: onClearGif ?? () {},
              ),

              // Button row: 😊 | GIF | 📷  ...  input  ...  send
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 😊 Emoji
                  Semantics(
                    label: '이모지',
                    child: GestureDetector(
                      onTap: onEmojiTap,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Text('😊', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),

                  // GIF
                  Semantics(
                    label: 'GIF',
                    child: GestureDetector(
                      onTap: onGifTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300, width: 1.2),
                        ),
                        child: Text(
                          'GIF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),

                  // 📷 Image
                  Semantics(
                    label: '사진 첨부',
                    child: GestureDetector(
                      onTap: onImageTap,
                      child: Icon(
                        Icons.image_outlined,
                        size: 22,
                        color: attachedImages.isNotEmpty ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Text input
                  Expanded(
                    child: CompositedTransformTarget(
                      link: mentionLayerLink ?? LayerLink(),
                      child: Semantics(
                        label: '댓글 입력',
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          cursorColor: commentPrimaryColor,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '댓글을 입력하세요...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: replyToUserName != null ? Colors.green.shade50 : commentBgColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: replyToUserName != null
                                  ? const BorderSide(color: Color(0xFF2E7D32), width: 1.2)
                                  : BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: replyToUserName != null
                                  ? const BorderSide(color: Color(0xFF2E7D32), width: 1.2)
                                  : BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: replyToUserName != null
                                  ? const BorderSide(color: Color(0xFF2E7D32), width: 1.5)
                                  : BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => onSubmit(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Send
                  Semantics(
                    label: '전송',
                    child: GestureDetector(
                      onTap: onSubmit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (hasText || hasAttachments) ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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

// ═══════════════════════════════════════════════════════════════
// Attachment Preview
// ═══════════════════════════════════════════════════════════════

class _AttachmentPreview extends StatelessWidget {
  final List<String> images;
  final String? gifUrl;
  final VoidCallback onClearImages;
  final VoidCallback onClearGif;

  const _AttachmentPreview({
    required this.images,
    required this.gifUrl,
    required this.onClearImages,
    required this.onClearGif,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            // Images 3-col grid preview
            if (images.isNotEmpty) ...[
              Expanded(
                child: SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length > 5 ? 5 : images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 4),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Image.network(images[i], width: 64, height: 72, fit: BoxFit.cover),
                          Positioned(
                            top: 2, right: 2,
                            child: GestureDetector(
                              onTap: onClearImages,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (images.length > 5)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text('+${images.length - 5}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
            ],

            // GIF preview
            if (gifUrl != null) ...[Expanded(
              child: SizedBox(
                height: 72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.network(gifUrl!, width: 120, height: 72, fit: BoxFit.cover),
                      Positioned(
                        top: 2, right: 2,
                        child: GestureDetector(
                          onTap: onClearGif,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )],
          ],
        ),
      ),
    );
  }
}
