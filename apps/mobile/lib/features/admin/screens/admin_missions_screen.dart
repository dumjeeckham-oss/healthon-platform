import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_provider.dart';
import '../admin_models.dart';

/// ===============================================================
/// HealthON — Admin Mission 관리 화면
/// ===============================================================

class AdminMissionsScreen extends ConsumerStatefulWidget {
  const AdminMissionsScreen({super.key});

  @override
  ConsumerState<AdminMissionsScreen> createState() =>
      _AdminMissionsScreenState();
}

class _AdminMissionsScreenState extends ConsumerState<AdminMissionsScreen> {
  String _periodLabel(MissionPeriod period) => switch (period) {
        MissionPeriod.daily => '매일',
        MissionPeriod.weekly => '매주',
        MissionPeriod.monthly => '매월',
      };

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final targetStepsCtrl = TextEditingController();
    final targetDistCtrl = TextEditingController();
    final rewardValueCtrl = TextEditingController();
    MissionPeriod period = MissionPeriod.daily;
    String rewardType = 'point';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('새 Mission 생성'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: '제목',
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
                    DropdownButtonFormField<MissionPeriod>(
                      value: period,
                      decoration: const InputDecoration(
                        labelText: '주기',
                        border: OutlineInputBorder(),
                      ),
                      items: MissionPeriod.values.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(_periodLabel(p)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => period = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: targetStepsCtrl,
                      decoration: const InputDecoration(
                        labelText: '목표 걸음 수',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '목표 걸음 수를 입력하세요';
                        if (int.tryParse(v.trim()) == null) return '숫자만 입력 가능합니다';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: targetDistCtrl,
                      decoration: const InputDecoration(
                        labelText: '목표 거리 (km)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '목표 거리를 입력하세요';
                        if (double.tryParse(v.trim()) == null) {
                          return '숫자만 입력 가능합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: rewardType,
                      decoration: const InputDecoration(
                        labelText: '보상 유형',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'point', child: Text('포인트')),
                        DropdownMenuItem(value: 'badge', child: Text('뱃지')),
                        DropdownMenuItem(value: 'item', child: Text('아이템')),
                        DropdownMenuItem(value: 'tree', child: Text('나무')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => rewardType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: rewardValueCtrl,
                      decoration: const InputDecoration(
                        labelText: '보상 수량',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '보상 수량을 입력하세요';
                        if (int.tryParse(v.trim()) == null) return '숫자만 입력 가능합니다';
                        return null;
                      },
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
                final repo = ref.read(adminRepositoryProvider);
                try {
                  await repo.createMission(AdminMissionDefinition(
                    id: '',
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    period: period,
                    targetSteps: int.parse(targetStepsCtrl.text.trim()),
                    targetDistanceKm: double.parse(targetDistCtrl.text.trim()),
                    rewardType: rewardType,
                    rewardValue: int.parse(rewardValueCtrl.text.trim()),
                    isActive: true,
                    createdAt: DateTime.now(),
                  ));
                  ref.invalidate(adminMissionsProvider);
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

  void _showEditDialog(AdminMissionDefinition mission) {
    final titleCtrl = TextEditingController(text: mission.title);
    final descCtrl = TextEditingController(text: mission.description);
    final targetStepsCtrl =
        TextEditingController(text: mission.targetSteps.toString());
    final targetDistCtrl =
        TextEditingController(text: mission.targetDistanceKm.toString());
    final rewardValueCtrl =
        TextEditingController(text: mission.rewardValue.toString());
    MissionPeriod period = mission.period;
    String rewardType = mission.rewardType;
    bool isActive = mission.isActive;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Mission 수정'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: '제목',
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
                    DropdownButtonFormField<MissionPeriod>(
                      value: period,
                      decoration: const InputDecoration(
                        labelText: '주기',
                        border: OutlineInputBorder(),
                      ),
                      items: MissionPeriod.values.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(_periodLabel(p)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => period = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: targetStepsCtrl,
                      decoration: const InputDecoration(
                        labelText: '목표 걸음 수',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '목표 걸음 수를 입력하세요';
                        if (int.tryParse(v.trim()) == null) return '숫자만 입력 가능합니다';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: targetDistCtrl,
                      decoration: const InputDecoration(
                        labelText: '목표 거리 (km)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '목표 거리를 입력하세요';
                        if (double.tryParse(v.trim()) == null) {
                          return '숫자만 입력 가능합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: rewardType,
                      decoration: const InputDecoration(
                        labelText: '보상 유형',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'point', child: Text('포인트')),
                        DropdownMenuItem(value: 'badge', child: Text('뱃지')),
                        DropdownMenuItem(value: 'item', child: Text('아이템')),
                        DropdownMenuItem(value: 'tree', child: Text('나무')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => rewardType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: rewardValueCtrl,
                      decoration: const InputDecoration(
                        labelText: '보상 수량',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '보상 수량을 입력하세요';
                        if (int.tryParse(v.trim()) == null) return '숫자만 입력 가능합니다';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('활성화'),
                      value: isActive,
                      onChanged: (v) => setDialogState(() => isActive = v),
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
                final repo = ref.read(adminRepositoryProvider);
                try {
                  await repo.updateMission(AdminMissionDefinition(
                    id: mission.id,
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    period: period,
                    targetSteps: int.parse(targetStepsCtrl.text.trim()),
                    targetDistanceKm: double.parse(targetDistCtrl.text.trim()),
                    rewardType: rewardType,
                    rewardValue: int.parse(rewardValueCtrl.text.trim()),
                    isActive: isActive,
                    createdAt: mission.createdAt,
                  ));
                  ref.invalidate(adminMissionsProvider);
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

  Future<void> _deleteMission(AdminMissionDefinition mission) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mission 삭제'),
        content: Text('"${mission.title}"을(를) 삭제하시겠습니까?'),
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
        await ref.read(adminRepositoryProvider).deleteMission(mission.id);
        ref.invalidate(adminMissionsProvider);
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

  String _rewardLabel(AdminMissionDefinition m) {
    final typeLabel = switch (m.rewardType) {
      'point' => '포인트',
      'badge' => '뱃지',
      'item' => '아이템',
      'tree' => '나무',
      _ => m.rewardType,
    };
    return '$typeLabel +${m.rewardValue}';
  }

  @override
  Widget build(BuildContext context) {
    final missionsAsync = ref.watch(adminMissionsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mission 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () => ref.invalidate(adminMissionsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('새 Mission'),
      ),
      body: missionsAsync.when(
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
        data: (missions) {
          if (missions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('등록된 Mission이 없습니다',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: missions.length,
            itemBuilder: (context, index) {
              final m = missions[index];
              return _MissionCard(
                mission: m,
                periodLabel: _periodLabel(m.period),
                rewardLabel: _rewardLabel(m),
                onEdit: () => _showEditDialog(m),
                onDelete: () => _deleteMission(m),
              );
            },
          );
        },
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final AdminMissionDefinition mission;
  final String periodLabel;
  final String rewardLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MissionCard({
    required this.mission,
    required this.periodLabel,
    required this.rewardLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mission.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    mission.isActive ? '활성' : '비활성',
                    style: TextStyle(
                      color: mission.isActive ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: mission.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  side: BorderSide.none,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
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
                        title: Text('삭제', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (mission.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                mission.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.repeat, size: 16, color: Colors.indigo),
                const SizedBox(width: 4),
                Text(periodLabel, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                const Icon(Icons.directions_walk, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '${mission.targetSteps} steps',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.straighten, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '${mission.targetDistanceKm} km',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.card_giftcard, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(rewardLabel, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
