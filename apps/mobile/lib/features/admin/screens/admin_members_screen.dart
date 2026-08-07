import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../admin_models.dart';
import '../admin_provider.dart';
import '../supabase_admin_repository.dart';

/// ===============================================================
/// HealthON — 회원 관리 화면 v2
///
/// StateNotifierProvider + Optimistic Update 기반.
/// 검색 / 필터칩 / 정렬 / 관리자·정지 토글 / CSV Export
/// ===============================================================

class AdminMembersScreen extends ConsumerStatefulWidget {
  const AdminMembersScreen({super.key});

  @override
  ConsumerState<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends ConsumerState<AdminMembersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // 필터 상태
  bool? _filterIsAdmin; // null → 전체, true → 관리자, false → 일반회원
  bool? _filterIsSuspended; // null → 전체, true → 정지, false → 활동중
  MemberSortField _sortField = MemberSortField.createdAt;
  MemberSortOrder _sortOrder = MemberSortOrder.desc;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminMembersProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  MemberFilter get _currentFilter => MemberFilter(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        isAdmin: _filterIsAdmin,
        isSuspended: _filterIsSuspended,
        sortField: _sortField,
        sortOrder: _sortOrder,
      );

  Future<void> _applyFilter() async {
    await ref.read(adminMembersProvider.notifier).load(filter: _currentFilter);
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value.trim());
    _applyFilter();
  }

  void _onFilterAdmin(bool? isAdmin) {
    setState(() => _filterIsAdmin = isAdmin);
    _applyFilter();
  }

  void _onFilterSuspended(bool? isSuspended) {
    setState(() => _filterIsSuspended = isSuspended);
    _applyFilter();
  }

  void _onSortChanged(MemberSortField field) {
    setState(() {
      if (_sortField == field) {
        _sortOrder = _sortOrder == MemberSortOrder.asc
            ? MemberSortOrder.desc
            : MemberSortOrder.asc;
      } else {
        _sortField = field;
        _sortOrder = MemberSortOrder.desc;
      }
    });
    _applyFilter();
  }

  Future<void> _exportCsv() async {
    final state = ref.read(adminMembersProvider);
    state.whenData((members) async {
      try {
        final repo = ref.read(adminRepositoryProvider);
        final csv = repo.exportMembersToCsv(members);

        // 시스템 Downloads 폴더에 저장
        final downloadsDir = Directory('${Platform.environment['USERPROFILE'] ?? Platform.environment['HOME']}/Downloads');
        final filePath = '${downloadsDir.path}/healthon_members_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
        final file = File(filePath);
        await file.writeAsString(csv, encoding: utf8);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CSV 내보내기 완료\n${file.path}'),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: '닫기',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CSV 내보내기 실패: $e'),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(adminMembersProvider);
    const dark = Color(0xFF1E1E2D);
    const accent = Color(0xFF2E7D32);

    return Column(
      children: [
        // ── 검색바 ──
        _SearchBar(
          controller: _searchController,
          dark: dark,
          accent: accent,
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 8),

        // ── 필터 칩 ──
        _FilterChips(
          filterIsAdmin: _filterIsAdmin,
          filterIsSuspended: _filterIsSuspended,
          sortField: _sortField,
          sortOrder: _sortOrder,
          accent: accent,
          onAdminFilter: _onFilterAdmin,
          onSuspendedFilter: _onFilterSuspended,
          onSortChanged: _onSortChanged,
        ),
        const SizedBox(height: 12),

        // ── 상단 액션바 (CSV Export) ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // 회원 수 표시
              membersAsync.when(
                data: (members) => Text(
                  '총 ${members.length}명',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const Spacer(),
              _ExportButton(onPressed: _exportCsv),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── 회원 목록 ──
        Expanded(
          child: membersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '회원 목록을 불러오지 못했습니다\n$err',
                  style: TextStyle(color: Colors.red[400], fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (members) {
              if (members.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline, size: 56, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty || _filterIsAdmin != null || _filterIsSuspended != null
                            ? '검색 결과가 없습니다'
                            : '등록된 회원이 없습니다',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _MemberCard(
                    member: members[index],
                    dark: dark,
                    accent: accent,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// 검색바
// ===============================================================

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Color dark;
  final Color accent;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.dark,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '이름, 이메일, 닉네임으로 검색',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: accent),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// 필터 칩
// ===============================================================

class _FilterChips extends StatelessWidget {
  final bool? filterIsAdmin;
  final bool? filterIsSuspended;
  final MemberSortField sortField;
  final MemberSortOrder sortOrder;
  final Color accent;
  final void Function(bool?) onAdminFilter;
  final void Function(bool?) onSuspendedFilter;
  final void Function(MemberSortField) onSortChanged;

  const _FilterChips({
    required this.filterIsAdmin,
    required this.filterIsSuspended,
    required this.sortField,
    required this.sortOrder,
    required this.accent,
    required this.onAdminFilter,
    required this.onSuspendedFilter,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // ── 역할 필터 ──
          _FilterChip(
            label: '전체',
            selected: filterIsAdmin == null && filterIsSuspended == null,
            color: accent,
            onTap: () {
              onAdminFilter(null);
              onSuspendedFilter(null);
            },
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: '관리자',
            selected: filterIsAdmin == true,
            color: accent,
            onTap: () => onAdminFilter(filterIsAdmin == true ? null : true),
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: '정지',
            selected: filterIsSuspended == true,
            color: Colors.red,
            onTap: () => onSuspendedFilter(filterIsSuspended == true ? null : true),
          ),
          const SizedBox(width: 12),
          // 구분선
          Container(width: 1, height: 18, color: Colors.grey[300]),
          const SizedBox(width: 12),
          // ── 정렬 옵션 ──
          _SortChip(
            label: '가입일',
            field: MemberSortField.createdAt,
            currentField: sortField,
            currentOrder: sortOrder,
            accent: accent,
            onSortChanged: onSortChanged,
          ),
          const SizedBox(width: 6),
          _SortChip(
            label: '이름',
            field: MemberSortField.name,
            currentField: sortField,
            currentOrder: sortOrder,
            accent: accent,
            onSortChanged: onSortChanged,
          ),
          const SizedBox(width: 6),
          _SortChip(
            label: '걸음',
            field: MemberSortField.steps,
            currentField: sortField,
            currentOrder: sortOrder,
            accent: accent,
            onSortChanged: onSortChanged,
          ),
          const SizedBox(width: 6),
          _SortChip(
            label: 'Forest',
            field: MemberSortField.forestLevel,
            currentField: sortField,
            currentOrder: sortOrder,
            accent: accent,
            onSortChanged: onSortChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey[300]!,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final MemberSortField field;
  final MemberSortField currentField;
  final MemberSortOrder currentOrder;
  final Color accent;
  final void Function(MemberSortField) onSortChanged;

  const _SortChip({
    required this.label,
    required this.field,
    required this.currentField,
    required this.currentOrder,
    required this.accent,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentField == field;
    final arrow = isActive
        ? (currentOrder == MemberSortOrder.asc ? ' ▲' : ' ▼')
        : '';

    return GestureDetector(
      onTap: () => onSortChanged(field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? accent.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? accent : Colors.grey[300]!,
            width: 1.2,
          ),
        ),
        child: Text(
          '$label$arrow',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? accent : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// CSV Export 버튼
// ===============================================================

class _ExportButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ExportButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.download, size: 16),
      label: const Text('CSV', style: TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2E7D32),
        side: const BorderSide(color: Color(0xFF2E7D32)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// ===============================================================
// 회원 카드
// ===============================================================

class _MemberCard extends StatelessWidget {
  final AdminMember member;
  final Color dark;
  final Color accent;

  const _MemberCard({
    required this.member,
    required this.dark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: isWide ? _buildWideLayout(context) : _buildNarrowLayout(context),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 사용자 정보 ──
        Expanded(
          flex: 3,
          child: _MemberInfo(member: member, dark: dark, accent: accent),
        ),
        // ── 통계 ──
        Expanded(
          flex: 2,
          child: _MemberStats(member: member, accent: accent, dark: dark),
        ),
        // ── 액션 버튼 ──
        SizedBox(
          width: 180,
          child: _MemberActions(member: member, accent: accent),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemberInfo(member: member, dark: dark, accent: accent),
        const Divider(height: 20),
        _MemberStats(member: member, accent: accent, dark: dark),
        const Divider(height: 20),
        _MemberActions(member: member, accent: accent),
      ],
    );
  }
}

// ===============================================================
// 회원 기본 정보
// ===============================================================

class _MemberInfo extends StatelessWidget {
  final AdminMember member;
  final Color dark;
  final Color accent;

  const _MemberInfo({
    required this.member,
    required this.dark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 아바타 ──
        CircleAvatar(
          radius: 22,
          backgroundColor: member.isAdmin ? accent.withOpacity(0.15) : dark.withOpacity(0.08),
          backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
              ? NetworkImage(member.avatarUrl!)
              : null,
          child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
              ? Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: member.isAdmin ? accent : dark,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 이름 + 닉네임 + 뱃지 ──
              Row(
                children: [
                  Flexible(
                    child: Text(
                      member.name,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: dark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (member.nickname != null && member.nickname!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '(${member.nickname})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (member.isAdmin) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ADMIN',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: accent),
                      ),
                    ),
                  ],
                  if (member.isSuspended) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '정지',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              // ── 이메일 ──
              Text(
                member.email,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // ── 가입일 + 최근 로그인 ──
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 11, color: Colors.grey[500]),
                  const SizedBox(width: 3),
                  Text(
                    '가입 ${_formatDate(member.createdAt)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.login, size: 11, color: Colors.grey[500]),
                  const SizedBox(width: 3),
                  Text(
                    member.lastLoginAt != null ? _formatDate(member.lastLoginAt!) : '없음',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
              if (member.joinSource != null && member.joinSource!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  '가입경로: ${member.joinSource}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

// ===============================================================
// 회원 통계
// ===============================================================

class _MemberStats extends StatelessWidget {
  final AdminMember member;
  final Color accent;
  final Color dark;

  const _MemberStats({required this.member, required this.accent, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        // Forest 레벨 + 나무종류
        _StatBadge(
          icon: Icons.forest,
          label: 'Forest Lv.${member.forestLevel} ${member.forestTreeType ?? ''}',
          color: accent,
        ),
        // 총 걸음
        _StatBadge(
          icon: Icons.directions_walk,
          label: _formatCount(member.totalSteps),
          color: const Color(0xFFE65100),
        ),
        // 총 거리
        _StatBadge(
          icon: Icons.straighten,
          label: '${member.totalDistanceKm.toStringAsFixed(1)} km',
          color: const Color(0xFF1565C0),
        ),
        // 챌린지 진행률
        if (member.challengeProgress > 0)
          _StatBadge(
            icon: Icons.trending_up,
            label: '도전 ${member.challengeProgress.toStringAsFixed(0)}%',
            color: const Color(0xFFF9A825),
          ),
        // 미션 완료
        _StatBadge(
          icon: Icons.assignment_turned_in,
          label: '미션 ${member.missionsCompleted}',
          color: const Color(0xFF6A1B9A),
        ),
        // 게시글
        _StatBadge(
          icon: Icons.article,
          label: '글 ${member.postCount}',
          color: const Color(0xFF00838F),
        ),
        // 댓글
        _StatBadge(
          icon: Icons.chat_bubble_outline,
          label: '댓글 ${member.commentCount}',
          color: const Color(0xFFAD1457),
        ),
        // 신고 (강조)
        _StatBadge(
          icon: Icons.report,
          label: '신고 ${member.reportCount}',
          color: member.reportCount > 0 ? Colors.red : Colors.grey,
        ),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만 걸음';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}천 걸음';
    return '$n 걸음';
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ===============================================================
// 회원 액션 버튼 (관리자 권한 / 활동정지)
// ===============================================================

class _MemberActions extends ConsumerWidget {
  final AdminMember member;
  final Color accent;

  const _MemberActions({required this.member, required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 관리자 권한 부여 / 회수 ──
        if (member.isAdmin)
          OutlinedButton.icon(
            onPressed: () => ref.read(adminMembersProvider.notifier).revokeAdmin(member.userId),
            icon: const Icon(Icons.admin_panel_settings, size: 16),
            label: const Text('관리자 회수', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange[800],
              side: BorderSide(color: Colors.orange[300]!),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () => ref.read(adminMembersProvider.notifier).grantAdmin(member.userId),
            icon: const Icon(Icons.admin_panel_settings, size: 16),
            label: const Text('관리자 부여', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: const BorderSide(color: Color(0xFF2E7D32)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        const SizedBox(height: 6),
        // ── 활동 정지 / 복구 ──
        if (member.isSuspended)
          OutlinedButton.icon(
            onPressed: () => ref.read(adminMembersProvider.notifier).restoreMember(member.userId),
            icon: const Icon(Icons.restore, size: 16),
            label: const Text('활동 복구', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: const BorderSide(color: Color(0xFF2E7D32)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () => ref.read(adminMembersProvider.notifier).suspendMember(member.userId),
            icon: const Icon(Icons.block, size: 16),
            label: const Text('활동 정지', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }
}
