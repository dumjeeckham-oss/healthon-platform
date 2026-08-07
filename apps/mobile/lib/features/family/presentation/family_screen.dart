/// ===============================================================
/// HealthON — Family Screen (Production)
///
/// 가족 없음 → 생성/가입
/// 가족 있음 → 대시보드 (랭킹 + 응원 + 챌린지)
/// ===============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/family_repository.dart';
import 'providers/family_provider.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});
  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(familyProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final familyAsync = ref.watch(familyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('가족'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (familyAsync.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: '초대코드 공유',
              onPressed: () =>
                  _showShareDialog(context, familyAsync.valueOrNull!.inviteCode),
            ),
        ],
      ),
      body: familyAsync.when(
        data: (family) => family == null
            ? const _NoFamilyView()
            : _FamilyDashboard(family: family),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('오류가 발생했습니다\n$e', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('초대 코드'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('아래 코드를 가족에게 공유하세요'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// 가족 없음
// ===============================================================

class _NoFamilyView extends ConsumerWidget {
  const _NoFamilyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinController = TextEditingController();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Icon(Icons.family_restroom, size: 80, color: Colors.green.shade200),
        const SizedBox(height: 16),
        const Text(
          '아직 가족이 없어요',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          '가족을 만들거나 초대코드로 참여하세요 👨‍👩‍👧',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        _ActionCard(
          icon: Icons.add_home,
          title: '새 가족 만들기',
          subtitle: '가족 그룹을 만들고 초대하세요',
          onTap: () => _showCreateDialog(context, ref),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.login, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 12),
                    const Text(
                      '초대코드로 참여',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: joinController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: '초대코드 6자리',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                  maxLength: 6,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final code = joinController.text.trim().toUpperCase();
                      if (code.length != 6) return;
                      final success = await ref
                          .read(familyProvider.notifier)
                          .joinFamily(code);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? '가족에 참여했어요! 🎉'
                                : '참여 실패. 코드를 확인해주세요'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('참여하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('새 가족 만들기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                hintText: '가족 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                hintText: '한줄 소개 (선택)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(familyProvider.notifier).createFamily(
                name: nameCtrl.text,
                description: descCtrl.text,
              );
            },
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32), size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ===============================================================
// 가족 대시보드 helper widgets (defined before use)
// ===============================================================

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white70),
      ),
    ],
  );
}

class _RankingTile extends StatelessWidget {
  final int rank;
  final FamilyRankingEntry entry;
  final double totalSteps;
  const _RankingTile({
    required this.rank,
    required this.entry,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final medal = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '$rank';
    final progress = totalSteps > 0
        ? (entry.todaySteps / (totalSteps / 1.5)).clamp(0.0, 1.0)
        : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Text(medal, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  entry.photoUrl != null ? NetworkImage(entry.photoUrl!) : null,
              child: entry.photoUrl == null
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name ?? '알 수 없음',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    backgroundColor: Colors.green.shade100,
                    color: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatNum(entry.todaySteps),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Lv.${entry.forestLevel} 🔥${entry.streak}일',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheerSection extends ConsumerWidget {
  final String familyId;
  const _CheerSection({required this.familyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💪 응원하기',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                '응원해요! 💪',
                '오늘도 화이팅! 🔥',
                '목표까지 조금만 더! 🎯',
                '대단해요! 🌟',
                '함께 달려요! 🏃',
              ].map((msg) => ActionChip(
                avatar: const Icon(Icons.favorite, size: 16, color: Colors.red),
                label: Text(msg, style: const TextStyle(fontSize: 12)),
                onPressed: () async {
                  final ranking = ref.read(familyRankingProvider(familyId));
                  ranking.whenData((list) {
                    if (list.isNotEmpty) {
                      ref.read(familyCheersProvider.notifier).sendCheer(
                        familyId: familyId,
                        toUserId: list.first.userId,
                        message: msg,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('응원을 보냈어요! 🎉'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  });
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 가족 대시보드
// ===============================================================

class _FamilyDashboard extends ConsumerWidget {
  final FamilyInfo family;
  const _FamilyDashboard({required this.family});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranking = ref.watch(familyRankingProvider(family.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(familyRankingProvider(family.id));
        ref.read(familyCheersProvider.notifier).load(family.id);
        ref.read(familyProvider.notifier).load();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 가족 헤더
          Card(
            color: const Color(0xFF2E7D32),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    family.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (family.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      family.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatChip(
                        label: '멤버',
                        value: '${family.memberCount}명',
                      ),
                      _StatChip(
                        label: '총 걸음',
                        value: _formatNum(family.totalSteps),
                      ),
                      _StatChip(
                        label: 'Forest Lv',
                        value: '${family.forestLevel}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 이번 주 목표 프로그레스
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이번 주 가족 목표 ${_formatNum(family.weeklyGoal)}걸음',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        (family.totalSteps / family.weeklyGoal).clamp(0.0, 1.0),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: Colors.green.shade100,
                    color: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(family.totalSteps / family.weeklyGoal * 100).toStringAsFixed(1)}% 달성',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 응원 보내기
          _CheerSection(familyId: family.id),
          const SizedBox(height: 16),

          // 랭킹
          const Text(
            '🏆 우리 가족 랭킹',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ranking.when(
            data: (list) {
              if (list.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        '아직 데이터가 없어요',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }
              final total =
                  list.fold<double>(0, (a, e) => a + e.todaySteps);
              return Column(
                children: List.generate(
                  list.length,
                  (i) => _RankingTile(
                    rank: i + 1,
                    entry: list[i],
                    totalSteps: total,
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('랭킹 로드 실패')),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

String _formatNum(int value) =>
    value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
