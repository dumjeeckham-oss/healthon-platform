import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_provider.dart';
import '../admin_models.dart';

/// ===============================================================
/// HealthON — Admin Notices Screen v2
///
/// StateNotifierProvider 기반 완전 재작성
/// 데이터 읽기: ref.watch(adminNoticesProvider) → AsyncValue
/// CRUD: ref.read(adminNoticesProvider.notifier).createNotice() 등
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
  void initState() {
    super.initState();
    // 초기 데이터 로드
    Future.microtask(() {
      ref.read(adminNoticesProvider.notifier).load();
    });
  }

  void _onCategoryChanged(String? category) {
    setState(() => _categoryFilter = category);
    // 카테고리 필터 변경 시 서버에서 다시 로드
    ref.read(adminNoticesProvider.notifier).load(category: category);
  }

  @override
  Widget build(BuildContext context) {
    final noticesAsync = ref.watch(adminNoticesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E2D),
        elevation: 0.5,
        title: const Text(
          '공지사항 관리',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
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
            onSelected: _onCategoryChanged,
          ),
          Expanded(
            child: noticesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        '데이터를 불러오지 못했습니다.\n$e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => ref.read(adminNoticesProvider.notifier).load(
                          category: _categoryFilter,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (notices) {
                if (notices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.campaign_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text(
                          '등록된 공지사항이 없습니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showCreateDialog(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('첫 공지 작성하기'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(adminNoticesProvider.notifier).load(
                      category: _categoryFilter,
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notices.length,
                    itemBuilder: (context, index) => _NoticeCard(
                      notice: notices[index],
                      onEdit: () => _showEditDialog(notices[index]),
                      onPublish: () => _publishNotice(notices[index]),
                      onSendPush: () => _sendPush(notices[index]),
                      onDelete: () => _confirmDelete(notices[index]),
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

  // ===========================================================
  // Create Notice Dialog
  // ===========================================================

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String category = 'notice';
    bool isPinned = false;
    bool isPublished = false;
    DateTime? scheduledAt;
    List<String> tags = [];
    List<String> imageUrls = [];
    List<({String name, String url})> attachments = [];

    final tagCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();
    final attachmentNameCtrl = TextEditingController();
    final attachmentUrlCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
        void _addTag() {
          final text = tagCtrl.text.trim();
          if (text.isNotEmpty && !tags.contains(text)) {
            setDialogState(() {
              tags = [...tags, text];
              tagCtrl.clear();
            });
          }
        }

        void _addImageUrl() {
          final url = imageUrlCtrl.text.trim();
          if (url.isNotEmpty && !imageUrls.contains(url)) {
            setDialogState(() {
              imageUrls = [...imageUrls, url];
              imageUrlCtrl.clear();
            });
          }
        }

        void _addAttachment() {
          final name = attachmentNameCtrl.text.trim();
          final url = attachmentUrlCtrl.text.trim();
          if (name.isNotEmpty && url.isNotEmpty) {
            setDialogState(() {
              attachments = [...attachments, (name: name, url: url)];
              attachmentNameCtrl.clear();
              attachmentUrlCtrl.clear();
            });
          }
        }

        return AlertDialog(
          title: const Text('새 공지 작성'),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- 제목 ----------
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---------- 내용 ----------
                  TextFormField(
                    controller: contentCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: '내용',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---------- 카테고리 ----------
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: '카테고리',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => category = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  // ---------- 태그 ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: tagCtrl,
                          decoration: const InputDecoration(
                            labelText: '태그',
                            hintText: '태그 입력 후 추가',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: FilledButton.tonalIcon(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('추가'),
                        ),
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: tags.map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setDialogState(() => tags = [...tags]..remove(t));
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // ---------- Image URLs ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: imageUrlCtrl,
                          decoration: const InputDecoration(
                            labelText: '이미지 URL',
                            hintText: 'https://...',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (_) => _addImageUrl(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: FilledButton.tonalIcon(
                          onPressed: _addImageUrl,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('추가'),
                        ),
                      ),
                    ],
                  ),
                  if (imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...imageUrls.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.red),
                            onPressed: () {
                              setDialogState(() {
                                imageUrls = [...imageUrls]..removeAt(entry.key);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 14),

                  // ---------- Attachment URLs ----------
                  const Text('첨부파일',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: attachmentNameCtrl,
                          decoration: const InputDecoration(
                            labelText: '파일명',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: attachmentUrlCtrl,
                          decoration: const InputDecoration(
                            labelText: 'URL',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onFieldSubmitted: (_) => _addAttachment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: IconButton.filledTonal(
                          onPressed: _addAttachment,
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
                  ),
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...attachments.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${entry.value.name} (${entry.value.url})',
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.red),
                            onPressed: () {
                              setDialogState(() {
                                attachments = [...attachments]..removeAt(entry.key);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 12),

                  // ---------- 스위치 ----------
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('상단 고정'),
                    value: isPinned,
                    onChanged: (v) => setDialogState(() => isPinned = v),
                    dense: true,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('발행'),
                    value: isPublished,
                    onChanged: (v) => setDialogState(() => isPublished = v),
                    dense: true,
                  ),

                  // ---------- 예약 발행 ----------
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule),
                    title: Text(
                      scheduledAt != null
                          ? '예약: ${_formatDateTime(scheduledAt!)}'
                          : '발행 예약 (선택)',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheduledAt != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    trailing: scheduledAt != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => setDialogState(() => scheduledAt = null),
                          )
                        : null,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: ctx,
                        initialDate: scheduledAt ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(scheduledAt ?? DateTime.now()),
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            scheduledAt = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // ---------- 액션 버튼 ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          tagCtrl.dispose();
                          imageUrlCtrl.dispose();
                          attachmentNameCtrl.dispose();
                          attachmentUrlCtrl.dispose();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('취소'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          if (titleCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('제목을 입력해주세요.')),
                            );
                            return;
                          }
                          final notice = AdminNotice(
                            id: '',
                            title: titleCtrl.text.trim(),
                            content: contentCtrl.text.trim(),
                            category: category,
                            tags: tags,
                            isPinned: isPinned,
                            isPublished: isPublished,
                            scheduledAt: scheduledAt,
                            imageUrls: imageUrls,
                            attachmentUrls: attachments.map((a) => a.url).toList(),
                            attachmentNames: attachments.map((a) => a.name).toList(),
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          try {
                            await ref.read(adminNoticesProvider.notifier).createNotice(notice);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('작성 실패: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('작성'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  }

  // ===========================================================
  // Edit Notice Dialog
  // ===========================================================

  void _showEditDialog(AdminNotice notice) {
    final titleCtrl = TextEditingController(text: notice.title);
    final contentCtrl = TextEditingController(text: notice.content);
    String category = notice.category;
    bool isPinned = notice.isPinned;
    bool isPublished = notice.isPublished;
    DateTime? scheduledAt = notice.scheduledAt;
    List<String> tags = [...notice.tags];
    List<String> imageUrls = [...notice.imageUrls];
    List<({String name, String url})> attachments = [];
    for (int i = 0; i < notice.attachmentUrls.length; i++) {
      final name = i < notice.attachmentNames.length ? notice.attachmentNames[i] : '';
      attachments.add((name: name, url: notice.attachmentUrls[i]));
    }

    final tagCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();
    final attachmentNameCtrl = TextEditingController();
    final attachmentUrlCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
        void _addTag() {
          final text = tagCtrl.text.trim();
          if (text.isNotEmpty && !tags.contains(text)) {
            setDialogState(() {
              tags = [...tags, text];
              tagCtrl.clear();
            });
          }
        }

        void _addImageUrl() {
          final url = imageUrlCtrl.text.trim();
          if (url.isNotEmpty && !imageUrls.contains(url)) {
            setDialogState(() {
              imageUrls = [...imageUrls, url];
              imageUrlCtrl.clear();
            });
          }
        }

        void _addAttachment() {
          final name = attachmentNameCtrl.text.trim();
          final url = attachmentUrlCtrl.text.trim();
          if (name.isNotEmpty && url.isNotEmpty) {
            setDialogState(() {
              attachments = [...attachments, (name: name, url: url)];
              attachmentNameCtrl.clear();
              attachmentUrlCtrl.clear();
            });
          }
        }

        return AlertDialog(
          title: const Text('공지 수정'),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- 제목 ----------
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---------- 내용 ----------
                  TextFormField(
                    controller: contentCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: '내용',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ---------- 카테고리 ----------
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: '카테고리',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => category = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  // ---------- 태그 ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: tagCtrl,
                          decoration: const InputDecoration(
                            labelText: '태그',
                            hintText: '태그 입력 후 추가',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: FilledButton.tonalIcon(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('추가'),
                        ),
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: tags.map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setDialogState(() => tags = [...tags]..remove(t));
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // ---------- Image URLs ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: imageUrlCtrl,
                          decoration: const InputDecoration(
                            labelText: '이미지 URL',
                            hintText: 'https://...',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (_) => _addImageUrl(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: FilledButton.tonalIcon(
                          onPressed: _addImageUrl,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('추가'),
                        ),
                      ),
                    ],
                  ),
                  if (imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...imageUrls.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.red),
                            onPressed: () {
                              setDialogState(() {
                                imageUrls = [...imageUrls]..removeAt(entry.key);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 14),

                  // ---------- Attachment URLs ----------
                  const Text('첨부파일',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: attachmentNameCtrl,
                          decoration: const InputDecoration(
                            labelText: '파일명',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: attachmentUrlCtrl,
                          decoration: const InputDecoration(
                            labelText: 'URL',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onFieldSubmitted: (_) => _addAttachment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: IconButton.filledTonal(
                          onPressed: _addAttachment,
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
                  ),
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...attachments.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${entry.value.name} (${entry.value.url})',
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.red),
                            onPressed: () {
                              setDialogState(() {
                                attachments = [...attachments]..removeAt(entry.key);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 12),

                  // ---------- 스위치 ----------
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('상단 고정'),
                    value: isPinned,
                    onChanged: (v) => setDialogState(() => isPinned = v),
                    dense: true,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('발행'),
                    value: isPublished,
                    onChanged: (v) => setDialogState(() => isPublished = v),
                    dense: true,
                  ),

                  // ---------- 예약 발행 ----------
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule),
                    title: Text(
                      scheduledAt != null
                          ? '예약: ${_formatDateTime(scheduledAt!)}'
                          : '발행 예약 (선택)',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheduledAt != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    trailing: scheduledAt != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => setDialogState(() => scheduledAt = null),
                          )
                        : null,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: ctx,
                        initialDate: scheduledAt ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(scheduledAt ?? DateTime.now()),
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            scheduledAt = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // ---------- 액션 버튼 ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          tagCtrl.dispose();
                          imageUrlCtrl.dispose();
                          attachmentNameCtrl.dispose();
                          attachmentUrlCtrl.dispose();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('취소'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          if (titleCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('제목을 입력해주세요.')),
                            );
                            return;
                          }
                          final updated = notice.copyWith(
                            title: titleCtrl.text.trim(),
                            content: contentCtrl.text.trim(),
                            category: category,
                            tags: tags,
                            isPinned: isPinned,
                            isPublished: isPublished,
                            scheduledAt: scheduledAt,
                            imageUrls: imageUrls,
                            attachmentUrls: attachments.map((a) => a.url).toList(),
                            attachmentNames: attachments.map((a) => a.name).toList(),
                          );
                          try {
                            await ref.read(adminNoticesProvider.notifier).updateNotice(updated);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('수정 실패: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('저장'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  }

  // ===========================================================
  // Publish Notice
  // ===========================================================

  Future<void> _publishNotice(AdminNotice notice) async {
    final updated = notice.copyWith(isPublished: true);
    await ref.read(adminNoticesProvider.notifier).updateNotice(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공지가 발행되었습니다.')),
      );
    }
  }

  // ===========================================================
  // Delete Notice
  // ===========================================================

  Future<void> _confirmDelete(AdminNotice notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('공지 삭제'),
        content: Text('「${notice.title}」을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminNoticesProvider.notifier).deleteNotice(notice.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('공지가 삭제되었습니다.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }

  // ===========================================================
  // Send Push
  // ===========================================================

  Future<void> _sendPush(AdminNotice notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('푸시 발송'),
        content: Text('「${notice.title}」공지의 푸시 알림을\n전체 사용자에게 발송하시겠습니까?'),
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
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.sendPushForNotice(notice.id);
        // 푸시 발송 후 reload
        await ref.read(adminNoticesProvider.notifier).load(category: _categoryFilter);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('푸시 알림이 발송되었습니다.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('푸시 발송 실패: $e')),
          );
        }
      }
    }
  }

  // ===========================================================
  // Format Helpers
  // ===========================================================

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
                fontWeight: selected == null ? FontWeight.w600 : FontWeight.normal,
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
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
  final VoidCallback onPublish;
  final VoidCallback onSendPush;
  final VoidCallback onDelete;

  const _NoticeCard({
    required this.notice,
    required this.onEdit,
    required this.onPublish,
    required this.onSendPush,
    required this.onDelete,
  });

  static const _categoryLabels = {
    'notice': '공지',
    'corporate_news': '사내소식',
    'event': '이벤트',
    'education': '교육',
    'volunteer': '봉사',
    'training': '연수',
  };

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- 상단: 타이틀 + 팝업메뉴 ----
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (notice.isPinned) ...[
                  const Icon(Icons.push_pin, size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    notice.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
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
                      case 'publish':
                        onPublish();
                      case 'push':
                        onSendPush();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, size: 20),
                        title: Text('수정'),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    if (!notice.isPublished)
                      const PopupMenuItem(
                        value: 'publish',
                        child: ListTile(
                          leading: Icon(Icons.publish, size: 20),
                          title: Text('발행'),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    if (!notice.pushSent)
                      const PopupMenuItem(
                        value: 'push',
                        child: ListTile(
                          leading: Icon(Icons.notifications_active, size: 20),
                          title: Text('푸시 발송'),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, size: 20, color: Colors.red),
                        title: Text('삭제', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ---- 카테고리 + 태그 ----
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _StatusBadge(
                  label: _categoryLabels[notice.category] ?? notice.category,
                  color: const Color(0xFF2E7D32),
                ),
                if (notice.isPublished)
                  _StatusBadge(label: '발행', color: Colors.blue)
                else
                  _StatusBadge(label: '미발행', color: Colors.grey),
                if (notice.pushSent)
                  _StatusBadge(label: '푸시완료', color: Colors.orange),
                ...notice.tags.map((t) => Chip(
                  label: Text(t, style: const TextStyle(fontSize: 11)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                )),
              ],
            ),

            const SizedBox(height: 8),

            // ---- 하단: 날짜 + 조회수 ----
            Row(
              children: [
                Icon(Icons.calendar_today, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  _formatDate(notice.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                if (notice.scheduledAt != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.schedule, size: 13, color: Colors.orange.shade400),
                  const SizedBox(width: 4),
                  Text(
                    '예약: ${_formatDate(notice.scheduledAt!)}',
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade400),
                  ),
                ],
                const Spacer(),
                Icon(Icons.visibility, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text(
                  '${notice.viewCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// Status Badge
// ===============================================================

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
