import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_models.dart';
import '../admin_provider.dart';

/// ===============================================================
/// HealthON — 회원 관리 화면
///
/// 검색바 + 회원 목록 + 관리자/정지 토글
/// ===============================================================

class AdminMembersScreen extends ConsumerStatefulWidget {
  const AdminMembersScreen({super.key});

  @override
  ConsumerState<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends ConsumerState<AdminMembersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 12),

        // ── 회원 목록 ──
        Expanded(
          child: membersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '회원 목록을 불러오지 못했습니다\n${err.toString()}',
                  style: TextStyle(color: Colors.red[400], fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (members) {
              final filtered = _searchQuery.isEmpty
                  ? members
                  : members.where((m) {
                      final q = _searchQuery.toLowerCase();
                      return m.name.toLowerCase().contains(q) ||
                          m.email.toLowerCase().contains(q) ||
                          (m.nickname?.toLowerCase().contains(q) ?? false);
                    }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline, size: 56, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty ? '등록된 회원이 없습니다' : '검색 결과가 없습니다',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _MemberCard(
                    member: filtered[index],
                    dark: dark,
                    accent: accent,
                    onToggleAdmin: _toggleAdmin,
                    onToggleSuspend: _toggleSuspend,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _toggleAdmin(AdminMember member, bool value) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.toggleAdmin(member.userId, value);
      ref.invalidate(adminMembersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('관리자 권한 변경 실패: $e'), backgroundColor: Colors.red[700]),
        );
      }
      setState(() {}); // UI 롤백
    }
  }

  Future<void> _toggleSuspend(AdminMember member, bool value) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.toggleSuspend(member.userId, value);
      ref.invalidate(adminMembersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('활동 정지 변경 실패: $e'), backgroundColor: Colors.red[700]),
        );
      }
      setState(() {}); // UI 롤백
    }
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
// 회원 카드
// ===============================================================

class _MemberCard extends StatelessWidget {
  final AdminMember member;
  final Color dark;
  final Color accent;
  final Future<void> Function(AdminMember member, bool value) onToggleAdmin;
  final Future<void> Function(AdminMember member, bool value) onToggleSuspend;

  const _MemberCard({
    required this.member,
    required this.dark,
    required this.accent,
    required this.onToggleAdmin,
    required this.onToggleSuspend,
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
      children: [
        // 사용자 정보
        Expanded(
          flex: 3,
          child: _MemberInfo(member: member, dark: dark),
        ),
        // 통계
        Expanded(
          flex: 2,
          child: _MemberStats(member: member, accent: accent),
        ),
        // 토글
        SizedBox(
          width: 200,
          child: _ToggleSection(
            member: member,
            accent: accent,
            onToggleAdmin: onToggleAdmin,
            onToggleSuspend: onToggleSuspend,
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemberInfo(member: member, dark: dark),
        const Divider(height: 20),
        _MemberStats(member: member, accent: accent),
        const Divider(height: 20),
        _ToggleSection(
          member: member,
          accent: accent,
          onToggleAdmin: onToggleAdmin,
          onToggleSuspend: onToggleSuspend,
        ),
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

  const _MemberInfo({required this.member, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아바타
        CircleAvatar(
          radius: 22,
          backgroundColor: dark.withOpacity(0.08),
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: dark),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                ],
              ),
              const SizedBox(height: 2),
              Text(
                member.email,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: '가입: ${_formatDate(member.createdAt)}',
                  ),
                  const SizedBox(width: 10),
                  _InfoChip(
                    icon: Icons.login,
                    label: '로그인: ${member.lastLoginAt != null ? _formatDate(member.lastLoginAt!) : '없음'}',
                  ),
                ],
              ),
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

  const _MemberStats({required this.member, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _StatBadge(icon: Icons.directions_walk, label: '${_formatCount(member.totalSteps)} 걸음', color: const Color(0xFFE65100)),
        _StatBadge(icon: Icons.forest, label: 'Forest Lv.${member.forestLevel}', color: accent),
        _StatBadge(icon: Icons.warning_amber, label: '신고 ${member.reportCount}회', color: member.reportCount > 0 ? Colors.red : Colors.grey),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}천';
    return n.toString();
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
// 토글 섹션 (관리자 + 활동정지)
// ===============================================================

class _ToggleSection extends StatelessWidget {
  final AdminMember member;
  final Color accent;
  final Future<void> Function(AdminMember member, bool value) onToggleAdmin;
  final Future<void> Function(AdminMember member, bool value) onToggleSuspend;

  const _ToggleSection({
    required this.member,
    required this.accent,
    required this.onToggleAdmin,
    required this.onToggleSuspend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleRow(
            label: '관리자',
            value: member.isAdmin,
            activeColor: accent,
            onChanged: (val) => onToggleAdmin(member, val),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ToggleRow(
            label: '활동정지',
            value: member.isSuspended,
            activeColor: Colors.red,
            onChanged: (val) => onToggleSuspend(member, val),
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(width: 4),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            activeTrackColor: activeColor.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// 정보 칩 (가입일 / 로그인일)
// ===============================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.grey[500]),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }
}
