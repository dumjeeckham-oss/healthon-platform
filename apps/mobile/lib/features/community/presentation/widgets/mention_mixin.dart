import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/comment_mention_provider.dart';

/// ===============================================================
/// @Mention Autocomplete Mixin
///
/// TextField에 @ 입력 시 멘션 자동완성 오버레이를 제공합니다.
///
/// 사용법:
/// ```dart
/// class _MyWidgetState extends ConsumerState<MyWidget>
///     with MentionMixin<MyWidget> {
///   ...
/// ```
/// ===============================================================

mixin MentionMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final LayerLink _mentionLayerLink = LayerLink();
  OverlayEntry? _mentionOverlay;

  bool _mentionActive = false;
  String _mentionQuery = '';

  void _handleMentionDetection(String text, int cursorPos) {
    final atIndex = _findAtBeforeCursor(text, cursorPos);
    if (atIndex >= 0) {
      final query = text.substring(atIndex + 1, cursorPos);
      if (!query.contains(' ') && !query.contains('\n')) {
        _mentionQuery = query;
        if (!_mentionActive) {
          _mentionActive = true;
          ref.read(mentionUserProvider.notifier).search(query);
          _showMentionOverlay();
        } else {
          ref.read(mentionUserProvider.notifier).search(query);
        }
        return;
      }
    }
    _dismissMention();
  }

  int _findAtBeforeCursor(String text, int cursorPos) {
    for (int i = cursorPos - 1; i >= 0; i--) {
      if (text[i] == '@' && (i == 0 || text[i - 1] == ' ' || text[i - 1] == '\n')) {
        return i;
      }
      if (text[i] == ' ' || text[i] == '\n') break;
    }
    return -1;
  }

  void _showMentionOverlay() {
    _mentionOverlay?.remove();
    _mentionOverlay = OverlayEntry(
      builder: (_) => _MentionDropdown(
        layerLink: _mentionLayerLink,
        onSelect: _onMentionSelected,
        onDismiss: _dismissMention,
      ),
    );
    Overlay.of(context).insert(_mentionOverlay!);
  }

  void _onMentionSelected(String userId, String userName) {
    // 현재 텍스트에서 @query 부분을 @userName 으로 교체
    _dismissMention();
  }

  void _dismissMention() {
    _mentionActive = false;
    _mentionOverlay?.remove();
    _mentionOverlay = null;
    ref.read(mentionUserProvider.notifier).clear();
  }

  /// 부모에서 TextEditingController + onChanged 연결 시 호출
  void onMentionTextChanged(String text, int cursorPos) {
    _handleMentionDetection(text, cursorPos);
  }

  LayerLink get mentionLayerLink => _mentionLayerLink;

  bool get isMentionActive => _mentionActive;
}

class _MentionDropdown extends ConsumerWidget {
  final LayerLink layerLink;
  final void Function(String userId, String userName) onSelect;
  final VoidCallback onDismiss;

  const _MentionDropdown({
    required this.layerLink,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mentionUserProvider);

    if (!state.isLoading && state.users.isEmpty) {
      // 검색 결과 없음 — overlay 제거 안 하고 빈 리스트 보여줌
    }

    return Stack(
      children: [
        // Dismiss backdrop
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        Positioned(
          width: 220,
          child: CompositedTransformFollower(
            link: layerLink,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, -8),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: state.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                      )
                    : state.users.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('검색 결과가 없습니다', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shrinkWrap: true,
                            itemCount: state.users.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final user = state.users[i];
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.green.shade100,
                                  child: Text(user.name[0], style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
                                ),
                                title: Text(user.name, style: const TextStyle(fontSize: 13)),
                                onTap: () => onSelect(user.id, user.name),
                              );
                            },
                          ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
