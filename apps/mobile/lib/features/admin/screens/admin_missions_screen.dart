import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_provider.dart';
import '../admin_models.dart';

/// ===============================================================
/// HealthON — Admin Mission 관리 화면 v3
///
/// StateNotifierProvider 기반: .notifier.load() / .notifier.create*()
/// 새 AdminMissionDefinition 전체 필드 + AdminMissionCondition 지원
/// ===============================================================

class AdminMissionsScreen extends ConsumerStatefulWidget {
  const AdminMissionsScreen({super.key});

  @override
  ConsumerState<AdminMissionsScreen> createState() =>
      _AdminMissionsScreenState();
}

class _AdminMissionsScreenState extends ConsumerState<AdminMissionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminMissionsProvider.notifier).load();
    });
  }

  // ── Create Dialog ────────────────────────────────────────────

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();
    final targetStepsCtrl = TextEditingController();
    final targetDistCtrl = TextEditingController();
    final rewardValueCtrl = TextEditingController();
    final customDaysCtrl = TextEditingController();
    final condStepsCtrl = TextEditingController();
    final condDistCtrl = TextEditingController();
    final timeOfDayCtrl = TextEditingController();

    MissionPeriod period = MissionPeriod.daily;
    int customDays = 1;
    String rewardType = 'point';
    int condMinSteps = 0;
    double condMinDist = 0;
    String? timeOfDay;
    List<String> requiredDays = [];
    bool isRepeatable = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('새 Mission 생성'),
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
                    // ── Period ──
                    DropdownButtonFormField<MissionPeriod>(
                      value: period,
                      decoration: const InputDecoration(
                        labelText: '주기 *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: MissionPeriod.daily,
                          child: const Text('매일'),
                        ),
                        DropdownMenuItem(
                          value: MissionPeriod.weekly,
                          child: const Text('매주'),
                        ),
                        DropdownMenuItem(
                          value: MissionPeriod.monthly,
                          child: const Text('매월'),
                        ),
                        DropdownMenuItem(
                          value: MissionPeriod.custom,
                          child: const Text('커스텀'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => period = v);
                      },
                    ),
                    // ── customDays (only when period == custom) ──
                    if (period == MissionPeriod.custom) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: customDaysCtrl,
                        decoration: const InputDecoration(
                          labelText: '커스텀 일수',
                          hintText: '예: 3',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          customDays = int.tryParse(v) ?? 1;
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    // ── Target ──
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
                              if (double.tryParse(v.trim()) == null) {
                                return '숫자';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // ── Condition ──
                    const Text('추가 조건 (선택)',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: condStepsCtrl,
                            decoration: const InputDecoration(
                              labelText: '최소 걸음',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                condMinSteps = int.tryParse(v) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: condDistCtrl,
                            decoration: const InputDecoration(
                              labelText: '최소 거리(km)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (v) =>
                                condMinDist = double.tryParse(v) ?? 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: timeOfDayCtrl,
                      decoration: const InputDecoration(
                        labelText: '시간 조건 (HH:MM)',
                        hintText: '예: 07:00',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        timeOfDay = v.trim().isEmpty ? null : v.trim();
                      },
                    ),
                    const SizedBox(height: 8),
                    // ── Required days (weekly only) ──
                    if (period == MissionPeriod.weekly) ...[
                      const Text('필수 요일',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _weekDayLabels.entries.map((entry) {
                          final selected = requiredDays.contains(entry.key);
                          return FilterChip(
                            label: Text(entry.value,
                                style: const TextStyle(fontSize: 12)),
                            selected: selected,
                            onSelected: (v) {
                              setDialogState(() {
                                if (v) {
                                  requiredDays = [...requiredDays, entry.key];
                                } else {
                                  requiredDays = requiredDays
                                      .where((d) => d != entry.key)
                                      .toList();
                                }
                              });
                            },
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // ── Reward ──
                    const Text('보상',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: rewardType,
                            decoration: const InputDecoration(
                              labelText: '보상 유형',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'point', child: Text('포인트')),
                              DropdownMenuItem(
                                  value: 'badge', child: Text('뱃지')),
                              DropdownMenuItem(
                                  value: 'item', child: Text('아이템')),
                              DropdownMenuItem(
                                  value: 'tree', child: Text('나무')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => rewardType = v);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: rewardValueCtrl,
                            decoration: const InputDecoration(
                              labelText: '보상 수량 *',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return '필수';
                              if (int.tryParse(v.trim()) == null) return '숫자';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('반복 가능'),
                      value: isRepeatable,
                      onChanged: (v) =>
                          setDialogState(() => isRepeatable = v),
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

                final hasCondition = condMinSteps > 0 ||
                    condMinDist > 0 ||
                    timeOfDay != null ||
                    requiredDays.isNotEmpty;

                final newMission = AdminMissionDefinition(
                  id: '',
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  imageUrl: imageUrlCtrl.text.trim().isEmpty
                      ? null
                      : imageUrlCtrl.text.trim(),
                  period: period,
                  customDays: customDays,
                  targetSteps:
                      int.tryParse(targetStepsCtrl.text.trim()) ?? 0,
                  targetDistanceKm:
                      double.tryParse(targetDistCtrl.text.trim()) ?? 0,
                  condition: hasCondition
                      ? AdminMissionCondition(
                          minSteps: condMinSteps,
                          minDistanceKm: condMinDist,
                          timeOfDay: timeOfDay,
                          requiredDays:
                              requiredDays.isNotEmpty ? requiredDays : null,
                        )
                      : null,
                  rewardType: rewardType,
                  rewardValue: int.tryParse(rewardValueCtrl.text.trim()) ?? 0,
                  isRepeatable: isRepeatable,
                  isActive: true,
                  completionCount: 0,
                  createdAt: DateTime.now(),
                );
                try {
                  await ref
                      .read(adminMissionsProvider.notifier)
                      .createMission(newMission);
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

  void _showEditDialog(AdminMissionDefinition m) {
    final titleCtrl = TextEditingController(text: m.title);
    final descCtrl = TextEditingController(text: m.description);
    final imageUrlCtrl = TextEditingController(text: m.imageUrl ?? '');
    final targetStepsCtrl =
        TextEditingController(text: m.targetSteps.toString());
    final targetDistCtrl =
        TextEditingController(text: m.targetDistanceKm.toString());
    final rewardValueCtrl =
        TextEditingController(text: m.rewardValue.toString());
    final customDaysCtrl =
        TextEditingController(text: m.customDays.toString());
    final condStepsCtrl =
        TextEditingController(text: (m.condition?.minSteps ?? 0).toString());
    final condDistCtrl = TextEditingController(
        text: (m.condition?.minDistanceKm ?? 0).toString());
    final timeOfDayCtrl =
        TextEditingController(text: m.condition?.timeOfDay ?? '');

    MissionPeriod period = m.period;
    int customDays = m.customDays;
    String rewardType = m.rewardType;
    int condMinSteps = m.condition?.minSteps ?? 0;
    double condMinDist = m.condition?.minDistanceKm ?? 0;
    String? timeOfDay = m.condition?.timeOfDay;
    List<String> requiredDays =
        m.condition?.requiredDays != null ? [...m.condition!.requiredDays!] : [];
    bool isRepeatable = m.isRepeatable;
    bool isActive = m.isActive;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Mission 수정'),
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
                    DropdownButtonFormField<MissionPeriod>(
                      value: period,
                      decoration: const InputDecoration(
                        labelText: '주기 *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: MissionPeriod.daily,
                          child: const Text('매일'),
                        ),
                        DropdownMenuItem(
                          value: MissionPeriod.weekly,
                          child: const Text('매주'),
                        ),
                        DropdownMenuItem(
                          value: MissionPeriod.monthly,
                          child: const Text('매월'),
                        ),
                        DropdownMenuItem(
                          value: MissionPeriod.custom,
                          child: const Text('커스텀'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => period = v);
                      },
                    ),
                    if (period == MissionPeriod.custom) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: customDaysCtrl,
                        decoration: const InputDecoration(
                          labelText: '커스텀 일수',
                          hintText: '예: 3',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          customDays = int.tryParse(v) ?? 1;
                        },
                      ),
                    ],
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
                              if (double.tryParse(v.trim()) == null) {
                                return '숫자';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('추가 조건 (선택)',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: condStepsCtrl,
                            decoration: const InputDecoration(
                              labelText: '최소 걸음',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                condMinSteps = int.tryParse(v) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: condDistCtrl,
                            decoration: const InputDecoration(
                              labelText: '최소 거리(km)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (v) =>
                                condMinDist = double.tryParse(v) ?? 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: timeOfDayCtrl,
                      decoration: const InputDecoration(
                        labelText: '시간 조건 (HH:MM)',
                        hintText: '예: 07:00',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        timeOfDay = v.trim().isEmpty ? null : v.trim();
                      },
                    ),
                    const SizedBox(height: 8),
                    if (period == MissionPeriod.weekly) ...[
                      const Text('필수 요일',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _weekDayLabels.entries.map((entry) {
                          final selected = requiredDays.contains(entry.key);
                          return FilterChip(
                            label: Text(entry.value,
                                style: const TextStyle(fontSize: 12)),
                            selected: selected,
                            onSelected: (v) {
                              setDialogState(() {
                                if (v) {
                                  requiredDays = [...requiredDays, entry.key];
                                } else {
                                  requiredDays = requiredDays
                                      .where((d) => d != entry.key)
                                      .toList();
                                }
                              });
                            },
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Text('보상',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: rewardType,
                            decoration: const InputDecoration(
                              labelText: '보상 유형',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'point', child: Text('포인트')),
                              DropdownMenuItem(
                                  value: 'badge', child: Text('뱃지')),
                              DropdownMenuItem(
                                  value: 'item', child: Text('아이템')),
                              DropdownMenuItem(
                                  value: 'tree', child: Text('나무')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => rewardType = v);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: rewardValueCtrl,
                            decoration: const InputDecoration(
                              labelText: '보상 수량 *',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return '필수';
                              if (int.tryParse(v.trim()) == null) return '숫자';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('반복 가능'),
                      value: isRepeatable,
                      onChanged: (v) =>
                          setDialogState(() => isRepeatable = v),
                    ),
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

                final hasCondition = condMinSteps > 0 ||
                    condMinDist > 0 ||
                    timeOfDay != null ||
                    requiredDays.isNotEmpty;

                final updated = AdminMissionDefinition(
                  id: m.id,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  imageUrl: imageUrlCtrl.text.trim().isEmpty
                      ? null
                      : imageUrlCtrl.text.trim(),
                  period: period,
                  customDays: customDays,
                  targetSteps:
                      int.tryParse(targetStepsCtrl.text.trim()) ?? 0,
                  targetDistanceKm:
                      double.tryParse(targetDistCtrl.text.trim()) ?? 0,
                  condition: hasCondition
                      ? AdminMissionCondition(
                          minSteps: condMinSteps,
                          minDistanceKm: condMinDist,
                          timeOfDay: timeOfDay,
                          requiredDays:
                              requiredDays.isNotEmpty ? requiredDays : null,
                        )
                      : null,
                  rewardType: rewardType,
                  rewardValue: int.tryParse(rewardValueCtrl.text.trim()) ?? 0,
                  isRepeatable: isRepeatable,
                  isActive: isActive,
                  completionCount: m.completionCount,
                  createdAt: m.createdAt,
                );
                try {
                  await ref
                      .read(adminMissionsProvider.notifier)
                      .updateMission(updated);
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

  Future<void> _deleteMission(AdminMissionDefinition m) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mission 삭제'),
        content: Text('"${m.title}"을(를) 삭제하시겠습니까?'),
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
        await ref.read(adminMissionsProvider.notifier).deleteMission(m.id);
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

  // ── Helpers ──────────────────────────────────────────────────

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

  String _conditionSummary(AdminMissionCondition? cond) {
    if (cond == null) return '없음';
    final parts = <String>[];
    if (cond.minSteps > 0) {
      parts.add('최소 ${_formatNumber(cond.minSteps)} steps');
    }
    if (cond.minDistanceKm > 0) {
      parts.add('최소 ${cond.minDistanceKm} km');
    }
    if (cond.timeOfDay != null && cond.timeOfDay!.isNotEmpty) {
      parts.add(cond.timeOfDay!);
    }
    if (cond.requiredDays != null && cond.requiredDays!.isNotEmpty) {
      final dayNames =
          cond.requiredDays!.map((d) => _weekDayLabels[d] ?? d).join(',');
      parts.add(dayNames);
    }
    return parts.isEmpty ? '없음' : parts.join(' · ');
  }

  // ── Build ────────────────────────────────────────────────────

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
            onPressed: () =>
                ref.read(adminMissionsProvider.notifier).load(),
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
                periodLabel: m.periodLabel,
                rewardLabel: _rewardLabel(m),
                conditionSummary: _conditionSummary(m.condition),
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

// ── Constants ──────────────────────────────────────────────────

const _weekDayLabels = {
  'mon': '월',
  'tue': '화',
  'wed': '수',
  'thu': '목',
  'fri': '금',
  'sat': '토',
  'sun': '일',
};

// ── Helpers ────────────────────────────────────────────────────

String _formatNumber(int n) {
  if (n >= 10000) {
    return '${(n / 10000).toStringAsFixed(1)}만';
  }
  return n.toString();
}

// ── Mission Card ───────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  final AdminMissionDefinition mission;
  final String periodLabel;
  final String rewardLabel;
  final String conditionSummary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MissionCard({
    required this.mission,
    required this.periodLabel,
    required this.rewardLabel,
    required this.conditionSummary,
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
          if (mission.imageUrl != null && mission.imageUrl!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 140,
              child: Image.network(
                mission.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
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
                        mission.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _MissionActiveChip(isActive: mission.isActive),
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

                // ── Period + Targets ──
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _MissionInfoChip(
                      icon: Icons.repeat,
                      iconColor: Colors.indigo,
                      label: periodLabel,
                    ),
                    _MissionInfoChip(
                      icon: Icons.directions_walk,
                      iconColor: Colors.green,
                      label: '${_formatNumber(mission.targetSteps)} steps',
                    ),
                    _MissionInfoChip(
                      icon: Icons.straighten,
                      iconColor: Colors.blue,
                      label: '${mission.targetDistanceKm} km',
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Condition + Reward ──
                Row(
                  children: [
                    const Icon(Icons.rule, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        conditionSummary,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.card_giftcard,
                        size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      rewardLabel,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Footer: repeatable, completions ──
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (mission.isRepeatable)
                      Chip(
                        avatar: const Icon(Icons.loop,
                            size: 16, color: Colors.teal),
                        label: const Text('반복 가능',
                            style: TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        side: BorderSide.none,
                      ),
                    Chip(
                      avatar: const Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.grey),
                      label: Text(
                        '${mission.completionCount}회 완료',
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      side: BorderSide.none,
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

class _MissionActiveChip extends StatelessWidget {
  final bool isActive;
  const _MissionActiveChip({required this.isActive});

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
          isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MissionInfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _MissionInfoChip({
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
