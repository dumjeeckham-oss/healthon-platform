import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_models.dart';
import '../admin_provider.dart';

/// ===============================================================
/// HealthON — 법인소식 관리 화면
///
/// Community와 별도로 운영되는 법인소식 (행사/교육/보수교육/공지/봉사)
/// CRUD + 예약발행 + 이미지 + 첨부파일 + 자동 Community Feed 등록
/// ===============================================================

class AdminNewsScreen extends ConsumerStatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  ConsumerState<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends ConsumerState<AdminNewsScreen> {
  String? _categoryFilter;

  static const _categories = {
    'event': '행사',
    'education': '교육',
    'training': '보수교육',
    'notice': '공지',
    'volunteer': '봉사',
  };

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(adminCorporateNewsProvider);

    return Column(
      children: [
        // ── 카테고리 필터 바 ──
        _CategoryFilterBar(
          selected: _categoryFilter,
          categories: _categories,
          onSelected: (v) => setState(() => _categoryFilter = v),
        ),
        const SizedBox(height: 8),
        // ── 목록 ──
        Expanded(
          child: newsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('법인소식 로드 실패\n$e',
                    style: TextStyle(color: Colors.red[400]), textAlign: TextAlign.center),
              ),
            ),
            data: (newsList) {
              final filtered = _categoryFilter == null
                  ? newsList
                  : newsList.where((n) => n.category == _categoryFilter).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.newspaper, size: 56, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        _categoryFilter == null ? '등록된 법인소식이 없습니다' : '해당 카테고리의 소식이 없습니다',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(adminCorporateNewsProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _NewsCard(
                    news: filtered[index],
                    onEdit: () => _showEditDialog(filtered[index]),
                    onDelete: () => _confirmDelete(filtered[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  // Edit Dialog
  // ────────────────────────────────────────────────────────────

  void _showEditDialog(CorporateNews news) {
    final titleCtrl = TextEditingController(text: news.title);
    final contentCtrl = TextEditingController(text: news.content);
    final authorCtrl = TextEditingController(text: news.authorName ?? '');
    String category = news.category ?? 'notice';
    bool isPublished = news.isPublished;
    bool isPinned = news.isPinned;
    bool autoFeed = news.autoFeed;
    DateTime? scheduledAt = news.scheduledAt;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('법인소식 수정'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: '제목', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contentCtrl,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: '내용',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: authorCtrl,
                    decoration: const InputDecoration(labelText: '작성자 (선택)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: '카테고리', border: OutlineInputBorder()),
                    items: _categories.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => category = v);
                    },
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('발행'),
                    value: isPublished,
                    onChanged: (v) => setDialogState(() => isPublished = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('상단 고정'),
                    value: isPinned,
                    onChanged: (v) => setDialogState(() => isPinned = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Community Feed 자동 등록'),
                    subtitle: const Text('발행 시 커뮤니티 피드에도 함께 노출'),
                    value: autoFeed,
                    onChanged: (v) => setDialogState(() => autoFeed = v),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule),
                    title: Text(
                      scheduledAt != null ? '예약: ${_formatDateTime(scheduledAt!)}' : '발행 예약 (선택)',
                      style: TextStyle(color: scheduledAt != null ? Colors.black87 : Colors.grey),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: scheduledAt ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && ctx.mounted) {
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(scheduledAt ?? DateTime.now()),
                        );
                        if (time != null) {
                          setDialogState(() {
                            scheduledAt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                    trailing: scheduledAt != null
                        ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setDialogState(() => scheduledAt = null))
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final repo = ref.read(adminRepositoryProvider);
                try {
                  final updated = news.copyWith(
                    title: titleCtrl.text.trim(),
                    content: contentCtrl.text.trim(),
                    category: category,
                    authorName: authorCtrl.text.trim().isEmpty ? null : authorCtrl.text.trim(),
                    isPublished: isPublished,
                    isPinned: isPinned,
                    scheduledAt: scheduledAt,
                    autoFeed: autoFeed,
                  );
                  await repo.updateCorporateNews(updated);
                  ref.invalidate(adminCorporateNewsProvider);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('법인소식이 수정되었습니다')),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('수정 실패: $e'), backgroundColor: Colors.red[700]),
                    );
                  }
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Delete
  // ────────────────────────────────────────────────────────────

  void _confirmDelete(CorporateNews news) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('법인소식 삭제'),
        content: Text('「${news.title}」을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('취소')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final repo = ref.read(adminRepositoryProvider);
              await repo.deleteCorporateNews(news.id);
              ref.invalidate(adminCorporateNewsProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
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

  const _CategoryFilterBar({required this.selected, required this.categories, required this.onSelected});

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
              labelStyle: TextStyle(color: selected == null ? Colors.white : Colors.black87),
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
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
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
// News Card
// ===============================================================

class _NewsCard extends StatelessWidget {
  final CorporateNews news;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NewsCard({required this.news, required this.onEdit, required this.onDelete});

  static const _categoryLabels = {
    'event': '행사',
    'education': '교육',
    'training': '보수교육',
    'notice': '공지',
    'volunteer': '봉사',
  };

  static const _categoryColors = {
    'event': Color(0xFFE65100),
    'education': Color(0xFF1565C0),
    'training': Color(0xFF6A1B9A),
    'notice': Color(0xFF2E7D32),
    'volunteer': Color(0xFF00838F),
  };

  @override
  Widget build(BuildContext context) {
    final catLabel = _categoryLabels[news.category] ?? news.category ?? '';
    final catColor = _categoryColors[news.category] ?? const Color(0xFF2E7D32);

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
                if (news.isPinned)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.push_pin, size: 16, color: Color(0xFF2E7D32)),
                  ),
                Expanded(
                  child: Text(
                    news.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('수정')),
                    const PopupMenuItem(value: 'delete', child: Text('삭제', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (news.content.isNotEmpty)
              Text(
                news.content,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Badge(label: catLabel, color: catColor),
                if (news.isPublished)
                  _Badge(label: '발행', color: Colors.blue)
                else
                  _Badge(label: '임시저장', color: Colors.grey),
                if (news.autoFeed)
                  _Badge(label: 'Feed연동', color: const Color(0xFF00838F)),
                if (news.authorName != null && news.authorName!.isNotEmpty)
                  _Badge(label: news.authorName!, color: Colors.indigo),
                if (news.scheduledAt != null)
                  _Badge(
                    label: '예약: ${news.scheduledAt!.month}/${news.scheduledAt!.day} ${news.scheduledAt!.hour}:${news.scheduledAt!.minute.toString().padLeft(2, '0')}',
                    color: Colors.orange,
                  ),
                if (news.images != null && news.images!.isNotEmpty)
                  _Badge(label: '📷 ${news.images!.length}', color: Colors.pink),
                if (news.attachments != null && news.attachments!.isNotEmpty)
                  _Badge(label: '📎 ${news.attachments!.length}', color: Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
