import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/community_comment.dart';
import '../providers/community_provider.dart';
import 'comment_widgets.dart';
import 'emoji_bottom_sheet.dart';
import 'gif_picker_bottom_sheet.dart';

/// ===============================================================
/// HealthON CommentSection — 고도화
///
/// 이모지 · GIF · 이미지 첨부 · @멘션 통합
/// ===============================================================

class CommentSection extends ConsumerStatefulWidget {
  final String postId;

  const CommentSection({super.key, required this.postId});

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final TextEditingController _composerCtrl = TextEditingController();
  final FocusNode _composerFocus = FocusNode();
  final LayerLink _mentionLayerLink = LayerLink();

  String? _replyToId;
  String? _replyToUserName;
  bool _composerHasText = false;

  /// 첨부 이미지
  List<String> _attachedImages = [];
  /// 첨부 GIF url
  String? _attachedGifUrl;

  @override
  void initState() {
    super.initState();
    _composerCtrl.addListener(() {
      final bool hasText = _composerCtrl.text.trim().isNotEmpty;
      if (_composerHasText != hasText) {
        setState(() { _composerHasText = hasText; });
      }
    });
  }

  @override
  void dispose() {
    _composerCtrl.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

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

  // ── 이모지 ──
  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => EmojiBottomSheet(
        onEmojiSelected: (emoji) {
          final text = _composerCtrl.text;
          final cursorPos = _composerCtrl.selection.baseOffset;
          final newText = text.substring(0, cursorPos - (cursorPos < 0 ? 0 : 0)) + emoji + text.substring(cursorPos < 0 ? text.length : cursorPos);
          // 실제 cursor 위치 기반 삽입
          final sel = _composerCtrl.selection;
          final start = sel.start;
          final end = sel.end;
          if (start >= 0) {
            final before = text.substring(0, start);
            final after = text.substring(end);
            _composerCtrl.text = '$before$emoji$after';
            final newPos = start + emoji.length;
            _composerCtrl.selection = TextSelection.collapsed(offset: newPos);
          } else {
            _composerCtrl.text = text + emoji;
          }
        },
      ),
    );
  }

  // ── GIF ──
  void _showGifPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => GifPickerBottomSheet(
        onGifSelected: (gifUrl) {
          setState(() { _attachedGifUrl = gifUrl; });
        },
      ),
    );
  }

  // ── Image ──
  void _showImagePicker() {
    // TODO: image_picker 연동 (gallery/camera)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이미지 선택 (image_picker 연동 예정)'), behavior: SnackBarBehavior.floating),
    );
  }

  void _clearImages() {
    setState(() { _attachedImages = []; });
  }

  void _clearGif() {
    setState(() { _attachedGifUrl = null; });
  }

  // ── Submit ──
  void _submitComment() {
    final String text = _composerCtrl.text.trim();
    final bool hasAttachments = _attachedImages.isNotEmpty || _attachedGifUrl != null;

    if (text.isEmpty && !hasAttachments) return;

    final List<String> mentions = _extractMentions(text);

    final CommunityComment comment = CommunityComment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      postId: widget.postId,
      userId: 'current_user',
      parentId: _replyToId,
      content: text.isNotEmpty ? text : '📎',
      mentions: mentions,
      images: _attachedImages,
      gifUrl: _attachedGifUrl,
      createdAt: DateTime.now(),
    );

    ref.read(addCommentProvider(comment).future);

    _composerCtrl.clear();
    _composerFocus.unfocus();

    setState(() {
      _replyToId = null;
      _replyToUserName = null;
      _composerHasText = false;
      _attachedImages = [];
      _attachedGifUrl = null;
    });
  }

  /// @username 패턴 추출
  List<String> _extractMentions(String text) {
    final regex = RegExp(r'@(\S+)');
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }

  // ── Delete ──
  void _deleteComment(String commentId) async {
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
    if (confirmed == true && mounted) {
      ref.read(deleteCommentProvider((postId: widget.postId, commentId: commentId)).future);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CommunityComment>> asyncComments =
        ref.watch(communityCommentsProvider(widget.postId));

    return Column(
      children: [
        const SizedBox(height: 12),
        const CommentHeader(),
        const SizedBox(height: 4),
        const CommentSortDropdown(),
        const SizedBox(height: 8),

        _CommentListCore(
          asyncComments: asyncComments,
          onReply: _startReply,
          onDelete: _deleteComment,
        ),

        const SizedBox(height: 8),

        CommentComposer(
          controller: _composerCtrl,
          focusNode: _composerFocus,
          hasText: _composerHasText,
          replyToUserName: _replyToUserName,
          onCancelReply: _cancelReply,
          onSubmit: _submitComment,
          onEmojiTap: _showEmojiPicker,
          onGifTap: _showGifPicker,
          onImageTap: _showImagePicker,
          mentionLayerLink: _mentionLayerLink,
          attachedImages: _attachedImages,
          attachedGifUrl: _attachedGifUrl,
          onClearImages: _clearImages,
          onClearGif: _clearGif,
        ),
      ],
    );
  }
}

// ===================================================================
// Comment List Core — with reply expand/collapse
// ===================================================================

class _CommentListCore extends StatefulWidget {
  final AsyncValue<List<CommunityComment>> asyncComments;
  final void Function({required String commentId, required String userName}) onReply;
  final void Function(String commentId) onDelete;

  const _CommentListCore({
    required this.asyncComments,
    required this.onReply,
    required this.onDelete,
  });

  @override
  State<_CommentListCore> createState() => _CommentListCoreState();
}

class _CommentListCoreState extends State<_CommentListCore> {
  final Set<String> _expandedReplyRoots = {};
  static const int _maxRepliesCollapsed = 3;

  @override
  Widget build(BuildContext context) {
    return widget.asyncComments.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4CAF50)),
          ),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('댓글을 불러올 수 없습니다', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      ),
      data: (comments) {
        if (comments.isEmpty) return const CommentEmpty();

        final roots = comments.where((c) => c.isRoot).toList();
        final lastId = comments.isNotEmpty ? comments.last.id : '';

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: ValueKey('comments_${comments.length}_$lastId'),
            children: roots.map((root) {
              final replies = comments.where((c) => c.parentId == root.id).toList();
              final hasReplies = replies.isNotEmpty;
              final repliesExpanded = _expandedReplyRoots.contains(root.id);
              final shouldCollapse = hasReplies && replies.length > _maxRepliesCollapsed;

              return Column(
                key: ValueKey('root_${root.id}'),
                children: [
                  CommentTile(
                    comment: root,
                    onReply: () => widget.onReply(commentId: root.id, userName: root.userId),
                    onDelete: () => widget.onDelete(root.id),
                  ),
                  if (hasReplies)
                    Padding(
                      padding: const EdgeInsets.only(left: 52),
                      child: Column(
                        children: [
                          ...replies
                              .take(repliesExpanded ? replies.length : _maxRepliesCollapsed)
                              .map((r) => CommentTile(
                                    key: ValueKey('reply_${r.id}'),
                                    comment: r,
                                    isReply: true,
                                    onReply: () => widget.onReply(commentId: r.id, userName: r.userId),
                                    onDelete: () => widget.onDelete(r.id),
                                  )),
                          if (shouldCollapse)
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  repliesExpanded
                                      ? _expandedReplyRoots.remove(root.id)
                                      : _expandedReplyRoots.add(root.id);
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 16),
                                  child: Row(
                                    children: [
                                      Container(width: 24, height: 1, color: Colors.grey.shade300),
                                      const SizedBox(width: 6),
                                      Text(
                                        repliesExpanded ? '답글 접기' : '답글 ${replies.length}개 보기',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
