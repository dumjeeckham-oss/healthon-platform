import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_provider.dart';
import '../admin_models.dart';

/// ===============================================================
/// HealthON — Admin Challenge 관리 화면 v3
///
/// StateNotifierProvider 기반: .notifier.load() / .notifier.create*()
/// 새 AdminChallengeDefinition 전체 필드 지원
/// ===============================================================

class AdminChallengesScreen extends ConsumerStatefulWidget {
  const AdminChallengesScreen({super.key});

  @override
  ConsumerState<AdminChallengesScreen> createState() =>
      _AdminChallengesScreenState();
}

class _AdminChallengesScreenState extends ConsumerState<AdminChallengesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminChallengesProvider.notifier).load();
    });
  }

  // ── Create Dialog ────────────────────────────────────────────

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();
    final targetStepsCtrl = TextEditingController();
    final targetDistCtrl = TextEditingController();
    final rewardCtrl = TextEditingController();
    final badgeNameCtrl = TextEditingController();
    final badgeImageUrlCtrl = TextEditingController();
    final forestBonusCtrl = TextEditingController();
    final participationLimitCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    bool autoStart = false;
    bool autoEnd = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('새 Challenge 생성'),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: '제목 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '제목을 입력하세요' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: '설명',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: imageUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: '이미지 URL',
                        hintText: 'https://...',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: targetStepsCtrl,
                            decoration: const InputDecoration(
                              labelText: '목표 걸음 수 *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return '필수';
                              if (int.tryParse(v.trim()) == null) return '숫자';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: targetDistCtrl,
                            decoration: const InputDecoration(
                              labelText: '목표 거리 (km) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return '필수';
                              if (double.tryParse(v.trim()) == null) return '숫자';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: rewardCtrl,
                      decoration: const InputDecoration(
                        labelText: '보상',
                        hintText: '예: 1,000 포인트 + 특별 배지',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: badgeNameCtrl,
                            decoration: const InputDecoration(
                              labelText: '배지 이름',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: badgeImageUrlCtrl,
                            decoration: const InputDecoration(
                              labelText: '배지 이미지 URL',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.url,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: forestBonusCtrl,
                            decoration: const InputDecoration(
                              labelText: '숲 보너스',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: participationLimitCtrl,
                            decoration: const InputDecoration(
                              labelText: '참여 제한 (0=무제한)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('자동 시작'),
                      value: autoStart,
                      onChanged: (v) => setDialogState(() => autoStart = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('자동 종료'),
                      value: autoEnd,
                      onChanged: (v) => setDialogState(() => autoEnd = v),
                    ),
                    _DateTile(
                      label: '시작일',
                      date: startDate,
                      onChanged: (d) => setDialogState(() => startDate = d),
                    ),
                    _DateTile(
                      label: '종료일',
                      date: endDate,
                      onChanged: (d) => setDialogState(() => endDate = d),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final newChallenge = AdminChallengeDefinition(
                  id: '',
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  imageUrl: imageUrlCtrl.text.trim().isEmpty
                      ? null
                      : imageUrlCtrl.text.trim(),
                  targetSteps: int.tryParse(targetStepsCtrl.text.trim()) ?? 0,
                  targetDistanceKm:
                      double.tryParse(targetDistCtrl.text.trim()) ?? 0,
                  reward: rewardCtrl.text.trim(),
                  badgeName: badgeNameCtrl.text.trim().isEmpty
                      ? null
                      : badgeNameCtrl.text.trim(),
                  badgeImageUrl: badgeImageUrlCtrl.text.trim().isEmpty
                      ? null
                      : badgeImageUrlCtrl.text.trim(),
                  forestBonus: int.tryParse(forestBonusCtrl.text.trim()) ?? 0,
                  participationLimit:
                      int.tryParse(participationLimitCtrl.text.trim()) ?? 0,
                  autoStart: autoStart,
                  autoEnd: autoEnd,
                  startDate: startDate,
                  endDate: endDate,
                  isActive: true,
                  participantCount: 0,
                  createdAt: DateTime.now(),
                );
                try {
                  await ref
                      .read(adminChallengesProvider.notifier)
                      .createChallenge(newChallenge);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('생성 실패: $e')),
                    );
                  }
                }
              },
              child: const Text('생성'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit Dialog ──────────────────────────────────────────────

  void _showEditDialog(AdminChallengeDefinition c) {
    final titleCtrl = TextEditingController(text: c.title);
    final descCtrl = TextEditingController(text: c.description);
    final imageUrlCtrl = TextEditingController(text: c.imageUrl ?? '');
    final targetStepsCtrl = TextEditingController(text: c.targetSteps.toString());
    final targetDistCtrl = TextEditingController(text: c.targetDistanceKm.toString());
    final rewardCtrl = TextEditingController(text: c.reward);
    final badgeNameCtrl = TextEditingController(text: c.badgeName ?? '');
    final badgeImageUrlCtrl = TextEditingController(text: c.badgeImageUrl ?? '');
    final forestBonusCtrl = TextEditingController(text: c.forestBonus.toString());
    final participationLimitCtrl =
        TextEditingController(text: c.participationLimit.toString());
    DateTime startDate = c.startDate;
    DateTime endDate = c.endDate;
    bool autoStart = c.autoStart;
    bool autoEnd = c.autoEnd;
    bool isActive = c.isActive;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Challenge 수정'),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: '제목 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '제목을 입력하세요' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: '설명',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: imageUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: '이미지 URL',
                        hintText: 'https://...',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: targetStepsCtrl,
                            decoration: const InputDecoration(
                              labelText: '목표 걸음 수 *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return '필수';
                              if (int.tryParse(v.trim()) == null) return '숫자';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: targetDistCtrl,
                            decoration: const InputDecoration(
                              labelText: '목표 거리 (km) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return '필수';
                              if (double.tryParse(v.trim()) == null) return '숫자';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: rewardCtrl,
                      decoration: const InputDecoration(
                        labelText: '보상',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: badgeNameCtrl,
                            decoration: const InputDecoration(
                              labelText: '배지 이름',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: badgeImageUrlCtrl,
                            decoration: const InputDecoration(
                              labelText: '배지 이미지 URL',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.url,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: forestBonusCtrl,
                            decoration: const InputDecoration(
                              labelText: '숲 보너스',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: participationLimitCtrl,
                            decoration: const InputDecoration(
                              labelText: '참여 제한 (0=무제한)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('자동 시작'),
                      value: autoStart,
                      onChanged: (v) => setDialogState(() => autoStart = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('자동 종료'),
                      value: autoEnd,
                      onChanged: (v) => setDialogState(() => autoEnd = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('활성화'),
                      value: isActive,
                      onChanged: (v) => setDialogState(() => isActive = v),
                    ),
                    _DateTile(
                      label: '시작일',
                      date: startDate,
                      onChanged: (d) => setDialogState(() => startDate = d),
                    ),
                    _DateTile(
                      label: '종료일',
                      date: endDate,
                      onChanged: (d) => setDialogState(() => endDate = d),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final updated = AdminChallengeDefinition(
                  id: c.id,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  imageUrl: imageUrlCtrl.text.trim().isEmpty
                      ? null
                      : imageUrlCtrl.text.trim(),
                  targetSteps: int.tryParse(targetStepsCtrl.text.trim()) ?? 0,
                  targetDistanceKm:
                      double.tryParse(targetDistCtrl.text.trim()) ?? 0,
                  reward: rewardCtrl.text.trim(),
                  badgeName: badgeNameCtrl.text.trim().isEmpty
                      ? null
                      : badgeNameCtrl.text.trim(),
                  badgeImageUrl: badgeImageUrlCtrl.text.trim().isEmpty
                      ? null
                      : badgeImageUrlCtrl.text.trim(),
                  forestBonus: int.tryParse(forestBonusCtrl.text.trim()) ?? 0,
                  participationLimit:
                      int.tryParse(participationLimitCtrl.text.trim()) ?? 0,
                  autoStart: autoStart,
                  autoEnd: autoEnd,
                  startDate: startDate,
                  endDate: endDate,
                  isActive: isActive,
                  participantCount: c.participantCount,
                  createdAt: c.createdAt,
                );
                try {
                  await ref
                      .read(adminChallengesProvider.notifier)
                      .updateChallenge(updated);
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
      ),
    );
  }

  // ── Delete ───────────────────────────────────────────────────

  Future<void> _deleteChallenge(AdminChallengeDefinition c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Challenge 삭제'),
        content: Text('"${c.title}"을(를) 삭제하시겠습니까?'),
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
        await ref.read(adminChallengesProvider.notifier).deleteChallenge(c.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('삭제되었습니다')),
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

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final challengesAsync = ref.watch(adminChallengesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Challenge 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () =>
                ref.read(adminChallengesProvider.notifier).load(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('새 Challenge'),
      ),
      body: challengesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('데이터를 불러오지 못했습니다.\n$err',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (challenges) {
          if (challenges.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('등록된 Challenge가 없습니다',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final c = challenges[index];
              return _ChallengeCard(
                challenge: c,
                onEdit: () => _showEditDialog(c),
                onDelete: () => _deleteChallenge(c),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

String _formatNumber(int n) {
  if (n >= 10000) {
    return '${(n / 10000).toStringAsFixed(1)}만';
  }
  return n.toString();
}

/// 재사용 가능한 DatePicker 타일
class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(_formatDate(date)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

// ── Challenge Card ─────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  final AdminChallengeDefinition challenge;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChallengeCard({
    required this.challenge,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──
          if (challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 160,
              child: Image.network(
                challenge.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image,
                        size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _ActiveChip(isActive: challenge.isActive),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('수정'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('삭제',
                                style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Description ──
                if (challenge.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    challenge.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 10),

                // ── Targets ──
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.directions_walk,
                      iconColor: Colors.green,
                      label:
                          '${_formatNumber(challenge.targetSteps)} steps',
                    ),
                    _InfoChip(
                      icon: Icons.straighten,
                      iconColor: Colors.blue,
                      label: '${challenge.targetDistanceKm} km',
                    ),
                    if (challenge.reward.isNotEmpty)
                      _InfoChip(
                        icon: Icons.card_giftcard,
                        iconColor: Colors.orange,
                        label: challenge.reward,
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Badge + Forest ──
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (challenge.badgeName != null &&
                        challenge.badgeName!.isNotEmpty)
                      Chip(
                        avatar: challenge.badgeImageUrl != null &&
                                challenge.badgeImageUrl!.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(challenge.badgeImageUrl!),
                              )
                            : const Icon(Icons.verified, size: 18),
                        label: Text(
                          challenge.badgeName!,
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.amber.withValues(alpha: 0.15),
                        side: BorderSide.none,
                      ),
                    if (challenge.forestBonus > 0)
                      Chip(
                        avatar: const Icon(Icons.forest, size: 18,
                            color: Colors.green),
                        label: Text(
                          '숲 +${challenge.forestBonus}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                        side: BorderSide.none,
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Footer: participants, dates, auto ──
                Row(
                  children: [
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.participantCount}명',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    if (challenge.autoStart)
                      const Icon(Icons.play_circle_outline,
                          size: 14, color: Colors.teal),
                    if (challenge.autoStart) const SizedBox(width: 2),
                    if (challenge.autoStart)
                      Text('자동시작',
                          style: TextStyle(
                              fontSize: 11, color: Colors.teal[700])),
                    if (challenge.autoEnd) const SizedBox(width: 8),
                    if (challenge.autoEnd)
                      const Icon(Icons.stop_circle,
                          size: 14, color: Colors.deepOrange),
                    if (challenge.autoEnd) const SizedBox(width: 2),
                    if (challenge.autoEnd)
                      Text('자동종료',
                          style: TextStyle(
                              fontSize: 11, color: Colors.deepOrange[700])),
                    const Spacer(),
                    Text(
                      '${_formatDate(challenge.startDate)} ~ ${_formatDate(challenge.endDate)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────

class _ActiveChip extends StatelessWidget {
  final bool isActive;
  const _ActiveChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        isActive ? '활성' : '비활성',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.grey,
          fontSize: 12,
        ),
      ),
      backgroundColor:
          isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
