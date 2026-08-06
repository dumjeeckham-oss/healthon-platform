import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_models.dart';
import '../admin_provider.dart';
import '../supabase_admin_repository.dart';

/// ===============================================================
/// HealthON — Banner 관리 화면
/// ===============================================================

class AdminBannersScreen extends ConsumerStatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  ConsumerState<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends ConsumerState<AdminBannersScreen> {
  Future<void> _createBanner() async {
    final result = await showDialog<AdminBanner>(
      context: context,
      builder: (ctx) => const _CreateBannerDialog(),
    );
    if (result == null) return;

    final repo = ref.read(adminRepositoryProvider);
    try {
      await repo.createBanner(result);
      ref.invalidate(adminBannersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('배너 생성 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editBanner(AdminBanner banner) async {
    final result = await showDialog<AdminBanner>(
      context: context,
      builder: (ctx) => _EditBannerDialog(banner: banner),
    );
    if (result == null) return;

    final repo = ref.read(adminRepositoryProvider);
    try {
      await repo.updateBanner(result);
      ref.invalidate(adminBannersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('배너 수정 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteBanner(AdminBanner banner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('배너 삭제'),
        content: Text('이 배너를 삭제하시겠습니까?\n\n${banner.imageUrl}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final repo = ref.read(adminRepositoryProvider);
    try {
      await repo.deleteBanner(banner.id);
      ref.invalidate(adminBannersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('배너 삭제 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleActive(AdminBanner banner) async {
    final updated = AdminBanner(
      id: banner.id,
      imageUrl: banner.imageUrl,
      linkUrl: banner.linkUrl,
      sortOrder: banner.sortOrder,
      startDate: banner.startDate,
      endDate: banner.endDate,
      isActive: !banner.isActive,
      createdAt: banner.createdAt,
    );

    final repo = ref.read(adminRepositoryProvider);
    try {
      await repo.updateBanner(updated);
      ref.invalidate(adminBannersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상태 변경 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(adminBannersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: bannersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('데이터를 불러오지 못했습니다.\n$err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(adminBannersProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (banners) {
          if (banners.isEmpty) {
            return const Center(child: Text('등록된 배너가 없습니다.', style: TextStyle(color: Colors.grey)));
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: banners.length,
            onReorder: (oldIndex, newIndex) {
              // 실제 정렬 순서 업데이트
              final repo = ref.read(adminRepositoryProvider);
              final list = List<AdminBanner>.from(banners);
              final item = list.removeAt(oldIndex);
              list.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);

              // 각 배너의 sortOrder 업데이트
              for (int i = 0; i < list.length; i++) {
                final updated = AdminBanner(
                  id: list[i].id,
                  imageUrl: list[i].imageUrl,
                  linkUrl: list[i].linkUrl,
                  sortOrder: i,
                  startDate: list[i].startDate,
                  endDate: list[i].endDate,
                  isActive: list[i].isActive,
                  createdAt: list[i].createdAt,
                );
                repo.updateBanner(updated);
              }
            },
            buildDefaultDragHandles: false,
            itemBuilder: (_, i) {
              final banner = banners[i];
              return _BannerListTile(
                key: ValueKey(banner.id),
                banner: banner,
                index: i,
                onEdit: () => _editBanner(banner),
                onDelete: () => _deleteBanner(banner),
                onToggleActive: () => _toggleActive(banner),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createBanner,
        icon: const Icon(Icons.add),
        label: const Text('새 배너'),
      ),
    );
  }
}

// ===============================================================
// 배너 목록 타일
// ===============================================================

class _BannerListTile extends StatelessWidget {
  final AdminBanner banner;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _BannerListTile({
    super.key,
    required this.banner,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = now.isAfter(banner.endDate);
    final isUpcoming = now.isBefore(banner.startDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 드래그 핸들
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Icon(Icons.drag_handle, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            // 이미지 미리보기
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 60,
                child: Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 정보 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('#${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      if (isUpcoming)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('예정', style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                        ),
                      if (isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('만료', style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    banner.linkUrl ?? '링크 없음',
                    style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(banner.startDate)} ~ ${_formatDate(banner.endDate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // 액션 영역
            Column(
              children: [
                // 활성화 Switch
                Switch(
                  value: banner.isActive,
                  onChanged: (_) => onToggleActive(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: onEdit,
                      tooltip: '수정',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: '삭제',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
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
// 새 배너 생성 다이얼로그
// ===============================================================

class _CreateBannerDialog extends StatefulWidget {
  const _CreateBannerDialog();

  @override
  State<_CreateBannerDialog> createState() => _CreateBannerDialogState();
}

class _CreateBannerDialogState extends State<_CreateBannerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlCtrl = TextEditingController();
  final _linkUrlCtrl = TextEditingController();
  final _sortOrderCtrl = TextEditingController(text: '0');
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _imageUrlCtrl.dispose();
    _linkUrlCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(picked)) _endDate = picked.add(const Duration(days: 1));
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final banner = AdminBanner(
      id: '',
      imageUrl: _imageUrlCtrl.text.trim(),
      linkUrl: _linkUrlCtrl.text.trim().isEmpty ? null : _linkUrlCtrl.text.trim(),
      sortOrder: int.tryParse(_sortOrderCtrl.text) ?? 0,
      startDate: _startDate,
      endDate: _endDate,
      isActive: true,
      createdAt: DateTime.now(),
    );
    Navigator.pop(context, banner);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 배너'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(
                  labelText: '이미지 URL',
                  hintText: 'https://example.com/banner.jpg',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '이미지 URL을 입력하세요';
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme) return '유효한 URL을 입력하세요';
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkUrlCtrl,
                decoration: const InputDecoration(labelText: '링크 URL (선택)', hintText: 'https://example.com/event'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sortOrderCtrl,
                decoration: const InputDecoration(labelText: '정렬 순서'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '순서를 입력하세요';
                  if (int.tryParse(v.trim()) == null) return '숫자를 입력하세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDate(true),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: '시작일'),
                  child: Row(
                    children: [
                      Text(_formatDate(_startDate), style: const TextStyle(fontSize: 15)),
                      const Spacer(),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDate(false),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: '종료일'),
                  child: Row(
                    children: [
                      Text(_formatDate(_endDate), style: const TextStyle(fontSize: 15)),
                      const Spacer(),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(onPressed: _submit, child: const Text('생성')),
      ],
    );
  }
}

// ===============================================================
// 배너 수정 다이얼로그
// ===============================================================

class _EditBannerDialog extends StatefulWidget {
  final AdminBanner banner;
  const _EditBannerDialog({required this.banner});

  @override
  State<_EditBannerDialog> createState() => _EditBannerDialogState();
}

class _EditBannerDialogState extends State<_EditBannerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _linkUrlCtrl;
  late final TextEditingController _sortOrderCtrl;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _imageUrlCtrl = TextEditingController(text: widget.banner.imageUrl);
    _linkUrlCtrl = TextEditingController(text: widget.banner.linkUrl ?? '');
    _sortOrderCtrl = TextEditingController(text: widget.banner.sortOrder.toString());
    _startDate = widget.banner.startDate;
    _endDate = widget.banner.endDate;
  }

  @override
  void dispose() {
    _imageUrlCtrl.dispose();
    _linkUrlCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(picked)) _endDate = picked.add(const Duration(days: 1));
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updated = AdminBanner(
      id: widget.banner.id,
      imageUrl: _imageUrlCtrl.text.trim(),
      linkUrl: _linkUrlCtrl.text.trim().isEmpty ? null : _linkUrlCtrl.text.trim(),
      sortOrder: int.tryParse(_sortOrderCtrl.text) ?? widget.banner.sortOrder,
      startDate: _startDate,
      endDate: _endDate,
      isActive: widget.banner.isActive,
      createdAt: widget.banner.createdAt,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('배너 수정'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 이미지 미리보기
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.network(
                    widget.banner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(labelText: '이미지 URL'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '이미지 URL을 입력하세요';
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme) return '유효한 URL을 입력하세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkUrlCtrl,
                decoration: const InputDecoration(labelText: '링크 URL (선택)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sortOrderCtrl,
                decoration: const InputDecoration(labelText: '정렬 순서'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '순서를 입력하세요';
                  if (int.tryParse(v.trim()) == null) return '숫자를 입력하세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDate(true),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: '시작일'),
                  child: Row(
                    children: [
                      Text(_formatDate(_startDate), style: const TextStyle(fontSize: 15)),
                      const Spacer(),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDate(false),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: '종료일'),
                  child: Row(
                    children: [
                      Text(_formatDate(_endDate), style: const TextStyle(fontSize: 15)),
                      const Spacer(),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(onPressed: _submit, child: const Text('저장')),
      ],
    );
  }
}

// ===============================================================
// Helpers
// ===============================================================

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
