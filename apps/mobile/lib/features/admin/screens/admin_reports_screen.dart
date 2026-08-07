import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_provider.dart';
import '../admin_models.dart';

/// ===============================================================
/// HealthON — Admin Reports Screen v2
///
/// StateNotifierProvider 기반 완전 재작성
/// 데이터 읽기: ref.watch(adminReportsProvider) → AsyncValue
/// 신고 처리: ref.read(adminReportsProvider.notifier).resolveReport()
/// ===============================================================

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  ReportStatus? _statusFilter;

  // null → '전체', ReportStatus enum → label
  static const _statusFilterMap = <ReportStatus?, String>{
    null: '전체',
    ReportStatus.pending: '대기',
    ReportStatus.reviewed: '검토완료',
    ReportStatus.deleted: '삭제',
    ReportStatus.hidden: '숨김',
    ReportStatus.warned: '경고',
    ReportStatus.suspended: '정지',
  };

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    Future.microtask(() {
      ref.read(adminReportsProvider.notifier).load();
    });
  }

  void _onStatusChanged(ReportStatus? status) {
    setState(() => _statusFilter = status);
    // 필터 변경 시 서버에서 다시 로드
    ref.read(adminReportsProvider.notifier).load(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(adminReportsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E2D),
        elevation: 0.5,
        title: const Text(
          '신고 관리',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          _StatusFilterBar(
            selected: _statusFilter,
            filters: _statusFilterMap,
            onSelected: _onStatusChanged,
          ),
          Expanded(
            child: reportsAsync.when(
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
                        onPressed: () => ref.read(adminReportsProvider.notifier).load(
                          status: _statusFilter,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (reports) {
                if (reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text(
                          '신고 내역이 없습니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(adminReportsProvider.notifier).load(
                      status: _statusFilter,
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) => _ReportCard(
                      report: reports[index],
                      onTap: () => _showActionSheet(reports[index]),
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
  // Action Sheet — 신고 처리 BottomSheet
  // ===========================================================

  void _showActionSheet(AdminReport report) {
    final isResolved = report.status != ReportStatus.pending;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---- 핸들 ----
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 14),

              // ---- 헤더 ----
              const Text(
                '신고 처리',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '신고자: ${report.reporterName}  ·  사유: ${report.reason}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // ---- 대상 콘텐츠 미리보기 ----
              if (report.targetContent != null && report.targetContent!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            report.targetType == 'comment' ? Icons.comment : Icons.article,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            report.targetType == 'comment' ? '댓글 내용' : '게시글 내용',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.targetContent!,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 4),

              // ---- 처리 완료된 경우: 처리 정보 표시 ----
              if (isResolved) ...[
                const Divider(indent: 20, endIndent: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: _statusColor(report.status),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '처리 완료',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(report.status),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _ResolvedInfoRow(
                        icon: Icons.shield,
                        label: '처리 유형',
                        value: _actionLabel(report.resolvedAction),
                      ),
                      const SizedBox(height: 4),
                      _ResolvedInfoRow(
                        icon: Icons.person,
                        label: '처리자',
                        value: report.resolvedBy ?? '-',
                      ),
                      const SizedBox(height: 4),
                      _ResolvedInfoRow(
                        icon: Icons.schedule,
                        label: '처리일시',
                        value: report.resolvedAt != null ? _formatDateTime(report.resolvedAt!) : '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // ---- 액션 버튼 (pending 상태만) ----
              if (!isResolved) ...[
                const Divider(indent: 20, endIndent: 20),
                const SizedBox(height: 4),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: const Text('검토 완료 (이상 없음)'),
                  subtitle: const Text('이상 없음으로 검토 완료'),
                  onTap: () => _handleResolve(ctx, report, ReportStatus.reviewed, '검토 완료 처리되었습니다.'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('게시글/댓글 삭제'),
                  subtitle: const Text('해당 콘텐츠를 삭제합니다'),
                  onTap: () => _handleResolve(ctx, report, ReportStatus.deleted, '콘텐츠가 삭제 처리되었습니다.'),
                ),
                ListTile(
                  leading: const Icon(Icons.visibility_off, color: Colors.orange),
                  title: const Text('숨김 처리'),
                  subtitle: const Text('해당 콘텐츠를 숨김 처리합니다'),
                  onTap: () => _handleResolve(ctx, report, ReportStatus.hidden, '콘텐츠가 숨김 처리되었습니다.'),
                ),
                ListTile(
                  leading: const Icon(Icons.warning_amber, color: Colors.amber),
                  title: const Text('작성자 경고'),
                  subtitle: const Text('작성자에게 경고를 부여합니다'),
                  onTap: () => _handleResolve(ctx, report, ReportStatus.warned, '작성자에게 경고가 부여되었습니다.'),
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.deepPurple),
                  title: const Text('작성자 정지'),
                  subtitle: const Text('작성자 계정을 정지합니다'),
                  onTap: () => _handleResolve(ctx, report, ReportStatus.suspended, '작성자가 정지 처리되었습니다.'),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // Handle Resolve
  // ===========================================================

  Future<void> _handleResolve(
    BuildContext sheetContext,
    AdminReport report,
    ReportStatus newStatus,
    String successMessage,
  ) async {
    Navigator.of(sheetContext).pop();
    try {
      await ref.read(adminReportsProvider.notifier).resolveReport(report.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('처리 실패: $e')),
        );
      }
    }
  }

  // ===========================================================
  // Helpers
  // ===========================================================

  Color _statusColor(ReportStatus status) => switch (status) {
    ReportStatus.pending => Colors.orange,
    ReportStatus.reviewed => Colors.green,
    ReportStatus.deleted => Colors.red,
    ReportStatus.hidden => Colors.grey,
    ReportStatus.warned => Colors.amber,
    ReportStatus.suspended => Colors.deepPurple,
  };

  String _actionLabel(String? action) => switch (action) {
    'deleted' => '콘텐츠 삭제',
    'hidden' => '숨김 처리',
    'warned' => '작성자 경고',
    'suspended' => '작성자 정지',
    'reviewed' => '검토 완료 (이상 없음)',
    _ => action ?? '-',
  };

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
    ReportStatus.pending => Colors.orange,
    ReportStatus.reviewed => Colors.green,
    ReportStatus.deleted => Colors.red,
    ReportStatus.hidden => Colors.grey,
    ReportStatus.warned => Colors.amber,
    ReportStatus.suspended => Colors.deepPurple,
  };

  IconData _statusIcon(ReportStatus status) => switch (status) {
    ReportStatus.pending => Icons.hourglass_empty,
    ReportStatus.reviewed => Icons.check_circle,
    ReportStatus.deleted => Icons.delete,
    ReportStatus.hidden => Icons.visibility_off,
    ReportStatus.warned => Icons.warning_amber,
    ReportStatus.suspended => Icons.block,
  };

  String _targetTypeLabel(String type) => type == 'comment' ? '댓글' : '게시글';

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(report.status);
    final isResolved = report.status != ReportStatus.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
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
              // ---- 상태 + 대상타입 + 날짜 ----
              Row(
                children: [
                  // 상태 Chip
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 대상 타입 Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

                  // 날짜
                  Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ---- 신고자 ----
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
              const SizedBox(height: 4),

              // ---- 대상 작성자 (있으면) ----
              if (report.targetAuthorName != null && report.targetAuthorName!.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '작성자: ${report.targetAuthorName}',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // ---- 사유 ----
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

              // ---- 상세 설명 ----
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

              // ---- 대상 콘텐츠 미리보기 (간략) ----
              if (report.targetContent != null && report.targetContent!.isNotEmpty) ...[
                const SizedBox(height: 6),
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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              // ---- 처리 완료 정보 ----
              if (isResolved && report.resolvedBy != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${report.resolvedBy}님이 ${_actionLabel(report.resolvedAction)} 처리'
                          '${report.resolvedAt != null ? " · ${_formatDate(report.resolvedAt!)}" : ""}',
                          style: TextStyle(fontSize: 12, color: statusColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _actionLabel(String? action) => switch (action) {
    'deleted' => '삭제',
    'hidden' => '숨김',
    'warned' => '경고',
    'suspended' => '정지',
    'reviewed' => '검토 완료',
    _ => action ?? '-',
  };
}

// ===============================================================
// Bottom Sheet Resolved Info Row
// ===============================================================

class _ResolvedInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResolvedInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
