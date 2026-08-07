import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_models.dart';
import '../admin_provider.dart';

/// ===============================================================
/// HealthON — Banner 관리 화면 (v3 — StateNotifierProvider)
///
/// - 데이터 읽기: ref.watch(adminBannersProvider) → AsyncValue
/// - 로드: ref.read(adminBannersProvider.notifier).load()
/// - 생성: ref.read(adminBannersProvider.notifier).createBanner(banner)
/// - 순서 변경: ref.read(adminBannersProvider.notifier).reorder(oldIndex, newIndex)
/// - 활성 토글: ref.read(adminBannersProvider.notifier).toggleBanner(id, active)
/// ===============================================================

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

IconData _linkTypeIcon(BannerLinkType type) => switch (type) {
  BannerLinkType.external_url => Icons.open_in_new,
  BannerLinkType.internal_route => Icons.route,
  BannerLinkType.none => Icons.link_off,
};

// ===============================================================
// Screen
// ===============================================================

class AdminBannersScreen extends ConsumerStatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  ConsumerState<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends ConsumerState<AdminBannersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminBannersProvider.notifier).load());
  }

  // ── 생성 ──────────────────────────────────────────────

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();
    final linkValueCtrl = TextEditingController();
    final sortOrderCtrl = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    BannerLinkType linkType = BannerLinkType.none;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('새 배너'),
          content: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: '배너 제목',
                        hintText: '예: 여름 한정 이벤트',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '제목을 입력하세요' : null,
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),

                    // 이미지 URL
                    TextFormField(
                      controller: imageUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: '이미지 URL',
                        hintText: 'https://example.com/banner.jpg',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '이미지 URL을 입력하세요';
                        final uri = Uri.tryParse(v.trim());
                        if (uri == null || !uri.hasScheme) return '유효한 URL을 입력하세요';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 링크 타입 (SegmentedButton)
                    const Text('링크 타입', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    SegmentedButton<BannerLinkType>(
                      segments: const [
                        ButtonSegment(
                          value: BannerLinkType.external_url,
                          label: Text('외부 링크'),
                          icon: Icon(Icons.open_in_new, size: 16),
                        ),
                        ButtonSegment(
                          value: BannerLinkType.internal_route,
                          label: Text('내부 경로'),
                          icon: Icon(Icons.route, size: 16),
                        ),
                        ButtonSegment(
                          value: BannerLinkType.none,
                          label: Text('없음'),
                          icon: Icon(Icons.link_off, size: 16),
                        ),
                      ],
                      selected: {linkType},
                      onSelectionChanged: (sel) {
                        setDialogState(() => linkType = sel.first);
                      },
                      showSelectedIcon: false,
                    ),
                    const SizedBox(height: 16),

                    // 링크 값 (linkType != none 일 때만)
                    if (linkType != BannerLinkType.none) ...[
                      TextFormField(
                        controller: linkValueCtrl,
                        decoration: InputDecoration(
                          labelText: linkType == BannerLinkType.external_url ? '외부 URL' : '내부 라우트',
                          hintText: linkType == BannerLinkType.external_url
                              ? 'https://example.com/event'
                              : '/event/123',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return '링크 값을 입력하세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 시작일 / 종료일
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  startDate = picked;
                                  if (endDate.isBefore(picked)) endDate = picked.add(const Duration(days: 1));
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: '시작일',
                                border: OutlineInputBorder(),
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(_formatDate(startDate), style: const TextStyle(fontSize: 14))),
                                  const Icon(Icons.calendar_today, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) setDialogState(() => endDate = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: '종료일',
                                border: OutlineInputBorder(),
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(_formatDate(endDate), style: const TextStyle(fontSize: 14))),
                                  const Icon(Icons.calendar_today, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 정렬 순서
                    TextFormField(
                      controller: sortOrderCtrl,
                      decoration: const InputDecoration(
                        labelText: '정렬 순서',
                        hintText: '0부터 시작',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '순서를 입력하세요';
                        if (int.tryParse(v.trim()) == null) return '숫자를 입력하세요';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final banner = AdminBanner(
                  id: '',
                  title: titleCtrl.text.trim(),
                  imageUrl: imageUrlCtrl.text.trim(),
                  linkValue: linkType != BannerLinkType.none ? linkValueCtrl.text.trim() : null,
                  linkType: linkType,
                  sortOrder: int.tryParse(sortOrderCtrl.text) ?? 0,
                  startDate: startDate,
                  endDate: endDate,
                  isActive: true,
                  clickCount: 0,
                  createdAt: DateTime.now(),
                );

                Navigator.pop(ctx);
                ref.read(adminBannersProvider.notifier).createBanner(banner).catchError((e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('배너 생성 실패: $e'), backgroundColor: Colors.red),
                    );
                  }
                });
              },
              child: const Text('생성'),
            ),
          ],
        ),
      ),
    );
  }

  // ── 수정 ──────────────────────────────────────────────

  void _showEditDialog(AdminBanner banner) {
    final titleCtrl = TextEditingController(text: banner.title);
    final imageUrlCtrl = TextEditingController(text: banner.imageUrl);
    final linkValueCtrl = TextEditingController(text: banner.linkValue ?? '');
    final sortOrderCtrl = TextEditingController(text: banner.sortOrder.toString());
    final formKey = GlobalKey<FormState>();

    BannerLinkType linkType = banner.linkType;
    DateTime startDate = banner.startDate;
    DateTime endDate = banner.endDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('배너 수정'),
          content: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지 미리보기
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Image.network(
                          banner.imageUrl,
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

                    // 제목
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: '배너 제목',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '제목을 입력하세요' : null,
                    ),
                    const SizedBox(height: 16),

                    // 이미지 URL
                    TextFormField(
                      controller: imageUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: '이미지 URL',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '이미지 URL을 입력하세요';
                        final uri = Uri.tryParse(v.trim());
                        if (uri == null || !uri.hasScheme) return '유효한 URL을 입력하세요';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 링크 타입
                    const Text('링크 타입', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    SegmentedButton<BannerLinkType>(
                      segments: const [
                        ButtonSegment(value: BannerLinkType.external_url, label: Text('외부'), icon: Icon(Icons.open_in_new, size: 16)),
                        ButtonSegment(value: BannerLinkType.internal_route, label: Text('내부'), icon: Icon(Icons.route, size: 16)),
                        ButtonSegment(value: BannerLinkType.none, label: Text('없음'), icon: Icon(Icons.link_off, size: 16)),
                      ],
                      selected: {linkType},
                      onSelectionChanged: (sel) {
                        setDialogState(() => linkType = sel.first);
                      },
                      showSelectedIcon: false,
                    ),
                    const SizedBox(height: 16),

                    if (linkType != BannerLinkType.none) ...[
                      TextFormField(
                        controller: linkValueCtrl,
                        decoration: InputDecoration(
                          labelText: linkType == BannerLinkType.external_url ? '외부 URL' : '내부 라우트',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return '링크 값을 입력하세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 날짜
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  startDate = picked;
                                  if (endDate.isBefore(picked)) endDate = picked.add(const Duration(days: 1));
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: '시작일', border: OutlineInputBorder()),
                              child: Row(children: [
                                Expanded(child: Text(_formatDate(startDate), style: const TextStyle(fontSize: 14))),
                                const Icon(Icons.calendar_today, size: 18),
                              ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) setDialogState(() => endDate = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: '종료일', border: OutlineInputBorder()),
                              child: Row(children: [
                                Expanded(child: Text(_formatDate(endDate), style: const TextStyle(fontSize: 14))),
                                const Icon(Icons.calendar_today, size: 18),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 정렬 순서
                    TextFormField(
                      controller: sortOrderCtrl,
                      decoration: const InputDecoration(labelText: '정렬 순서', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '순서를 입력하세요';
                        if (int.tryParse(v.trim()) == null) return '숫자를 입력하세요';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final updated = AdminBanner(
                  id: banner.id,
                  title: titleCtrl.text.trim(),
                  imageUrl: imageUrlCtrl.text.trim(),
                  linkValue: linkType != BannerLinkType.none ? linkValueCtrl.text.trim() : null,
                  linkType: linkType,
                  sortOrder: int.tryParse(sortOrderCtrl.text) ?? banner.sortOrder,
                  startDate: startDate,
                  endDate: endDate,
                  isActive: banner.isActive,
                  clickCount: banner.clickCount,
                  createdAt: banner.createdAt,
                );

                Navigator.pop(ctx);
                ref.read(adminBannersProvider.notifier).updateBanner(updated).catchError((e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('배너 수정 실패: $e'), backgroundColor: Colors.red),
                    );
                  }
                });
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  // ── 삭제 ──────────────────────────────────────────────

  Future<void> _deleteBanner(AdminBanner banner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('배너 삭제'),
        content: Text('"${banner.title}" 배너를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
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

    try {
      await ref.read(adminBannersProvider.notifier).deleteBanner(banner.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('배너가 삭제되었습니다.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('배너 삭제 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(adminBannersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('배너 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () => ref.read(adminBannersProvider.notifier).load(),
          ),
        ],
      ),
      body: bannersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 56, color: colorScheme.error),
                const SizedBox(height: 12),
                Text('데이터를 불러오지 못했습니다.', style: TextStyle(fontSize: 16, color: colorScheme.error)),
                const SizedBox(height: 8),
                Text('$err', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => ref.read(adminBannersProvider.notifier).load(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
        data: (banners) {
          if (banners.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.campaign_outlined, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('등록된 배너가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('FAB를 눌러 새 배너를 추가하세요.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: banners.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(adminBannersProvider.notifier).reorder(oldIndex, newIndex);
            },
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 4,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                child: child,
              );
            },
            itemBuilder: (_, i) {
              final banner = banners[i];
              return _BannerListTile(
                key: ValueKey(banner.id),
                banner: banner,
                index: i,
                onEdit: () => _showEditDialog(banner),
                onDelete: () => _deleteBanner(banner),
                onToggle: (active) {
                  ref.read(adminBannersProvider.notifier).toggleBanner(banner.id, active);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
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
  final ValueChanged<bool> onToggle;

  const _BannerListTile({
    super.key,
    required this.banner,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  String _linkTypeLabel(BannerLinkType type) => switch (type) {
    BannerLinkType.external_url => '외부 링크',
    BannerLinkType.internal_route => '내부 경로',
    BannerLinkType.none => '링크 없음',
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isUpcoming = now.isBefore(banner.startDate);
    final isExpired = now.isAfter(banner.endDate);
    final isActiveNow = banner.isActive && !isUpcoming && !isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 드래그 핸들
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Icon(Icons.drag_handle, color: Colors.grey, size: 24),
              ),
            ),
            const SizedBox(width: 8),

            // 이미지 미리보기
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 90,
                height: 68,
                child: Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 28),
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
                  // 제목 + 상태 뱃지
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          banner.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isUpcoming)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('예정', style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                        ),
                      if (isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('만료', style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.w600)),
                        ),
                      if (isActiveNow)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('진행중', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 링크 정보
                  Row(
                    children: [
                      Icon(_linkTypeIcon(banner.linkType), size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          banner.linkType != BannerLinkType.none && banner.linkValue != null
                              ? banner.linkValue!
                              : _linkTypeLabel(banner.linkType),
                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 기간
                  Text(
                    '${_formatDate(banner.startDate)} ~ ${_formatDate(banner.endDate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),

                  // 클릭 수 + 정렬 순서
                  Row(
                    children: [
                      Icon(Icons.touch_app_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 2),
                      Text(
                        '${banner.clickCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${banner.sortOrder}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 액션 영역
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 활성화 Switch
                Switch(
                  value: banner.isActive,
                  onChanged: onToggle,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                // PopupMenuButton
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (action) {
                    switch (action) {
                      case 'edit':
                        onEdit();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('수정'), dense: true, contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text('삭제', style: TextStyle(color: Colors.red)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
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
