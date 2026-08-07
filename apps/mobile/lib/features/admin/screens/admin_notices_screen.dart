import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_models.dart';
import '../admin_provider.dart';
/// ===============================================================
/// HealthON — Admin Notices Screen
/// 공지사항 관리 화면
/// ===============================================================

class AdminNoticesScreen extends ConsumerStatefulWidget {
  const AdminNoticesScreen({super.key});

  @override
  ConsumerState<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends ConsumerState<AdminNoticesScreen> {
  String? _categoryFilter;

  static const _categories = {
    'notice': '공지',
    'corporate_news': '사내소식',
    'event': '이벤트',
    'education': '교육',
    'volunteer': '봉사',
    'training': '연수',
  };

  @override
  Widget build(BuildContext context) {
    final noticesAsync = ref.watch(adminNoticesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E2D),
        elevation: 0.5,
        title: const Text('공지사항 관리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('새 공지'),
      ),
      body: Column(
        children: [
          _CategoryFilterBar(
            selected: _categoryFilter,
            categories: _categories,
            onSelected: (v) => setState(() => _categoryFilter = v),
          ),
          Expanded(
            child: noticesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (notices) {
                final filtered = _categoryFilter == null
                    ? notices
                    : notices.where((n) => n.category == _categoryFilter).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('등록된 공지사항이 없습니다.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(adminNoticesProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _NoticeCard(
                      notice: filtered[index],
                      onEdit: () => _showEditDialog(filtered[index]),
                      onDelete: () => _confirmDelete(filtered[index]),
                      onSendPush: () => _sendPush(filtered[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Create Notice Dialog
  // ---------------------------------------------------------------

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String category = 'notice';
    bool isPinned = false;
    bool isPublished = false;
    DateTime? scheduledAt;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('새 공지 작성'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contentCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => category = v);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('상단 고정'),
                  value: isPinned,
                  onChanged: (v) => setDialogState(() => isPinned = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('발행'),
                  value: isPublished,
                  onChanged: (v) => setDialogState(() => isPublished = v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: Text(
                    scheduledAt != null
                        ? '예약: ${_formatDate(scheduledAt!)}'
                        : '발행 예약 (선택)',
                    style: TextStyle(
                      color: scheduledAt != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: scheduledAt ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      if (!ctx.mounted) return;
                      final time = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.fromDateTime(scheduledAt ?? DateTime.now()),
                      );
                      if (time != null) {
                        setDialogState(() {
                          scheduledAt = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  trailing: scheduledAt != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setDialogState(() => scheduledAt = null),
                        )
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final repo = ref.read(adminRepositoryProvider);
                final notice = AdminNotice(
                  id: '',
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  category: category,
                  isPinned: isPinned,
                  isPublished: isPublished,
                  scheduledAt: scheduledAt,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await repo.createNotice(notice);
                ref.invalidate(adminNoticesProvider);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('작성'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Edit Notice Dialog
  // ---------------------------------------------------------------

  void _showEditDialog(AdminNotice notice) {
    final titleCtrl = TextEditingController(text: notice.title);
    final contentCtrl = TextEditingController(text: notice.content);
    String category = notice.category;
    bool isPinned = notice.isPinned;
    bool isPublished = notice.isPublished;
    DateTime? scheduledAt = notice.scheduledAt;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('공지 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contentCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => category = v);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('상단 고정'),
                  value: isPinned,
                  onChanged: (v) => setDialogState(() => isPinned = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('발행'),
                  value: isPublished,
                  onChanged: (v) => setDialogState(() => isPublished = v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: Text(
                    scheduledAt != null
                        ? '예약: ${_formatDate(scheduledAt!)}'
                        : '발행 예약 (선택)',
                    style: TextStyle(
                      color: scheduledAt != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: scheduledAt ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      if (!ctx.mounted) return;
                      final time = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.fromDateTime(scheduledAt ?? DateTime.now()),
                      );
                      if (time != null) {
                        setDialogState(() {
                          scheduledAt = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  trailing: scheduledAt != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setDialogState(() => scheduledAt = null),
                        )
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final repo = ref.read(adminRepositoryProvider);
                final updated = notice.copyWith(
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  category: category,
                  isPinned: isPinned,
                  isPublished: isPublished,
                  scheduledAt: scheduledAt,
                );
                await repo.updateNotice(updated);
                ref.invalidate(adminNoticesProvider);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Delete Confirm
  // ---------------------------------------------------------------

  void _confirmDelete(AdminNotice notice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('공지 삭제'),
        content: Text('「${notice.title}」을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final repo = ref.read(adminRepositoryProvider);
              await repo.deleteNotice(notice.id);
              ref.invalidate(adminNoticesProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Send Push
  // ---------------------------------------------------------------

  Future<void> _sendPush(AdminNotice notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('푸시 발송'),
        content: Text('「${notice.title}」공지의 푸시 알림을 발송하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('발송'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(adminRepositoryProvider);
      await repo.sendPushForNotice(notice.id);
      ref.invalidate(adminNoticesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('푸시 알림이 발송되었습니다.')),
        );
      }
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ===============================================================
// Category Filter Bar
// ===============================================================

class _CategoryFilterBar extends StatelessWidget {
  final String? selected;
  final Map<String, String> categories;
  final void Function(String?) onSelected;

  const _CategoryFilterBar({
    required this.selected,
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('전체'),
              selected: selected == null,
              selectedColor: const Color(0xFF2E7D32),
              labelStyle: TextStyle(
                color: selected == null ? Colors.white : Colors.black87,
              ),
              onSelected: (_) => onSelected(null),
            ),
            const SizedBox(width: 6),
            ...categories.entries.map((e) {
              final isSelected = selected == e.key;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2E7D32),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  onSelected: (_) => onSelected(isSelected ? null : e.key),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// Notice Card
// ===============================================================

class _NoticeCard extends StatelessWidget {
  final AdminNotice notice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSendPush;

  const _NoticeCard({
    required this.notice,
    required this.onEdit,
    required this.onDelete,
    required this.onSendPush,
  });

  static const _categoryLabels = {
    'notice': '공지',
    'corporate_news': '사내소식',
    'event': '이벤트',
    'education': '교육',
    'volunteer': '봉사',
    'training': '연수',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (notice.isPinned)
                  const Icon(Icons.push_pin, size: 16, color: Color(0xFF2E7D32)),
                if (notice.isPinned) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    notice.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  onSelected: (v) {
                    switch (v) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('수정')),
                    const PopupMenuItem(value: 'delete', child: Text('삭제', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatusBadge(
                  label: _categoryLabels[notice.category] ?? notice.category,
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(width: 6),
                if (notice.isPublished)
                  _StatusBadge(label: '발행', color: Colors.blue)
                else
                  _StatusBadge(label: '미발행', color: Colors.grey),
                const SizedBox(width: 6),
                _StatusBadge(
                  label: notice.pushSent ? '푸시완료' : '푸시미발송',
                  color: notice.pushSent ? Colors.orange : Colors.grey,
                ),
                const Spacer(),
                if (!notice.pushSent)
                  TextButton.icon(
                    icon: const Icon(Icons.notifications_active, size: 16),
                    label: const Text('푸시발송', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onSendPush,
                  ),
              ],
            ),
            if (notice.scheduledAt != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '예약: ${notice.scheduledAt!.year}-${notice.scheduledAt!.month.toString().padLeft(2, '0')}-${notice.scheduledAt!.day.toString().padLeft(2, '0')} ${notice.scheduledAt!.hour.toString().padLeft(2, '0')}:${notice.scheduledAt!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
