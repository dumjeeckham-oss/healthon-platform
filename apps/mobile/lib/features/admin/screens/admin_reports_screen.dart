import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_models.dart';
import '../admin_provider.dart';
import '../supabase_admin_repository.dart';

/// ===============================================================
/// HealthON — Admin Reports Screen
/// 신고 관리 화면
/// ===============================================================

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  ReportStatus? _statusFilter;

  static const _statusFilters = {
    null: '전체',
    ReportStatus.pending: '대기',
    ReportStatus.reviewed: '검토완료',
    ReportStatus.deleted: '삭제',
    ReportStatus.hidden: '숨김',
    ReportStatus.warned: '경고',
    ReportStatus.suspended: '정지',
  };

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(adminReportsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E2D),
        elevation: 0.5,
        title: const Text('신고 관리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _StatusFilterBar(
            selected: _statusFilter,
            filters: _statusFilters,
            onSelected: (v) => setState(() => _statusFilter = v),
          ),
          Expanded(
            child: reportsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (reports) {
                final filtered = _statusFilter == null
                    ? reports
                    : reports.where((r) => r.status == _statusFilter).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('신고 내역이 없습니다.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(adminReportsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _ReportCard(
                      report: filtered[index],
                      onTap: () => _showActionSheet(filtered[index]),
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
  // Action Sheet — 신고 처리 옵션
  // ---------------------------------------------------------------

  void _showActionSheet(AdminReport report) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '신고 처리',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '신고자: ${report.reporterName}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline, color: Colors.red),
                title: const Text('게시글/댓글 삭제'),
                subtitle: const Text('해당 콘텐츠를 삭제합니다'),
                onTap: () => _handleAction(ctx, report, ReportStatus.deleted, '콘텐츠가 삭제 처리되었습니다.'),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off, color: Colors.orange),
                title: const Text('숨김 처리'),
                subtitle: const Text('해당 콘텐츠를 숨김 처리합니다'),
                onTap: () => _handleAction(ctx, report, ReportStatus.hidden, '콘텐츠가 숨김 처리되었습니다.'),
              ),
              ListTile(
                leading: const Icon(Icons.warning_amber, color: Colors.amber),
                title: const Text('작성자 경고'),
                subtitle: const Text('작성자에게 경고를 부여합니다'),
                onTap: () => _handleAction(ctx, report, ReportStatus.warned, '작성자에게 경고가 부여되었습니다.'),
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.deepPurple),
                title: const Text('작성자 정지'),
                subtitle: const Text('작성자 계정을 정지합니다'),
                onTap: () => _handleAction(ctx, report, ReportStatus.suspended, '작성자가 정지 처리되었습니다.'),
              ),
              if (report.status == ReportStatus.pending)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: const Text('검토 완료 (이상없음)'),
                  subtitle: const Text('이상 없음으로 검토 완료합니다'),
                  onTap: () => _handleAction(ctx, report, ReportStatus.reviewed, '검토 완료 처리되었습니다.'),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext sheetContext,
    AdminReport report,
    ReportStatus newStatus,
    String successMessage,
  ) async {
    Navigator.of(sheetContext).pop();
    final repo = ref.read(adminRepositoryProvider);
    await repo.updateReportStatus(report.id, newStatus);
    ref.invalidate(adminReportsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    }
  }
}

// ===============================================================
// Status Filter Bar
// ===============================================================

class _StatusFilterBar extends StatelessWidget {
  final ReportStatus? selected;
  final Map<ReportStatus?, String> filters;
  final void Function(ReportStatus?) onSelected;

  const _StatusFilterBar({
    required this.selected,
    required this.filters,
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
          children: filters.entries.map((e) {
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
          }).toList(),
        ),
      ),
    );
  }
}

// ===============================================================
// Report Card
// ===============================================================

class _ReportCard extends StatelessWidget {
  final AdminReport report;
  final VoidCallback onTap;

  const _ReportCard({required this.report, required this.onTap});

  Color _statusColor(ReportStatus status) => switch (status) {
        ReportStatus.pending    => Colors.orange,
        ReportStatus.reviewed   => Colors.green,
        ReportStatus.deleted    => Colors.red,
        ReportStatus.hidden     => Colors.grey,
        ReportStatus.warned     => Colors.amber,
        ReportStatus.suspended  => Colors.deepPurple,
      };

  IconData _statusIcon(ReportStatus status) => switch (status) {
        ReportStatus.pending    => Icons.hourglass_empty,
        ReportStatus.reviewed   => Icons.check_circle,
        ReportStatus.deleted    => Icons.delete,
        ReportStatus.hidden     => Icons.visibility_off,
        ReportStatus.warned     => Icons.warning_amber,
        ReportStatus.suspended  => Icons.block,
      };

  String _targetTypeLabel(String type) => type == 'comment' ? '댓글' : '게시글';

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(report.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(report.status), size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          report.statusLabel,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _targetTypeLabel(report.targetType),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '신고자: ${report.reporterName}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '사유: ${report.reason}',
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (report.detail != null && report.detail!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        report.detail!,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (report.targetContent != null && report.targetContent!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    report.targetContent!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
