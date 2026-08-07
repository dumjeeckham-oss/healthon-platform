import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_models.dart';
import '../admin_provider.dart';

/// ===============================================================
/// HealthON — Forest 시즌 관리 화면 (v3 — StateNotifierProvider)
///
/// - 데이터 읽기: ref.watch(adminForestSeasonsProvider) → AsyncValue
/// - 로드: ref.read(adminForestSeasonsProvider.notifier).load()
/// - 생성: ref.read(adminForestSeasonsProvider.notifier).createSeason(season)
/// - 종료: ref.read(adminForestSeasonsProvider.notifier).endSeason(id)
/// ===============================================================

final _treeTypeOptions = const [
  '벚꽃나무',
  '소나무',
  '단풍나무',
  '겨울나무',
  '기본',
  '열대나무',
  '대나무',
];

final _effectOptions = const ['blossom', 'snow', 'leaf', 'none'];
final _effectLabels = const ['벚꽃 흩날림', '눈 내림', '낙엽', '없음'];

Color _parseHexColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

String _colorToHex(Color c) {
  return '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

// ===============================================================
// Screen
// ===============================================================

class AdminSeasonsScreen extends ConsumerStatefulWidget {
  const AdminSeasonsScreen({super.key});

  @override
  ConsumerState<AdminSeasonsScreen> createState() => _AdminSeasonsScreenState();
}

class _AdminSeasonsScreenState extends ConsumerState<AdminSeasonsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminForestSeasonsProvider.notifier).load());
  }

  Future<void> _endSeason(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('시즌 종료'),
        content: Text('"$name" 시즌을 종료하시겠습니까?\n종료된 시즌은 비활성 목록으로 이동합니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('종료'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref.read(adminForestSeasonsProvider.notifier).endSeason(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('시즌 종료 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    ForestSeasonType seasonType = ForestSeasonType.spring;
    ForestSeasonTheme theme = ForestSeasonTheme.defaultFor(ForestSeasonType.spring);
    DateTime startDate = DateTime.now();
    Color primaryColor = _parseHexColor(theme.primaryColor);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('새 Forest 시즌'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 시즌 이름
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: '시즌 이름',
                        hintText: '예: 봄맞이 벚꽃 시즌',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '이름을 입력하세요' : null,
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),

                    // 시즌 타입 (SegmentedButton)
                    const Text('시즌 종류', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    SegmentedButton<ForestSeasonType>(
                      segments: const [
                        ButtonSegment(value: ForestSeasonType.spring, label: Text('🌸 봄')),
                        ButtonSegment(value: ForestSeasonType.summer, label: Text('☀️ 여름')),
                        ButtonSegment(value: ForestSeasonType.autumn, label: Text('🍂 가을')),
                        ButtonSegment(value: ForestSeasonType.winter, label: Text('❄️ 겨울')),
                      ],
                      selected: {seasonType},
                      onSelectionChanged: (sel) {
                        final st = sel.first;
                        final defaults = ForestSeasonTheme.defaultFor(st);
                        setDialogState(() {
                          seasonType = st;
                          theme = defaults;
                          primaryColor = _parseHexColor(defaults.primaryColor);
                        });
                      },
                      showSelectedIcon: false,
                    ),
                    const SizedBox(height: 16),

                    // 테마: 나무 종류
                    DropdownButtonFormField<String>(
                      initialValue: theme.treeType,
                      decoration: const InputDecoration(
                        labelText: '나무 종류',
                        border: OutlineInputBorder(),
                      ),
                      items: _treeTypeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => theme = ForestSeasonTheme(
                            treeType: v,
                            primaryColor: _colorToHex(primaryColor),
                            backgroundColor: theme.backgroundColor,
                            effect: theme.effect,
                            backgroundImageUrl: theme.backgroundImageUrl,
                          ));
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 테마: primaryColor 색상선택
                    const Text('주요 색상', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // 간단한 색상 프리셋
                            final presets = [
                              Colors.red, Colors.pink, Colors.purple,
                              Colors.deepPurple, Colors.indigo, Colors.blue,
                              Colors.lightBlue, Colors.cyan, Colors.teal,
                              Colors.green, Colors.lightGreen, Colors.lime,
                              Colors.yellow, Colors.amber, Colors.orange,
                              Colors.deepOrange, Colors.brown, Colors.grey,
                            ];
                            final color = await showDialog<Color>(
                              context: context,
                              builder: (c) => SimpleDialog(
                                title: const Text('색상 선택'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: presets.map((p) => GestureDetector(
                                        onTap: () => Navigator.pop(c, p),
                                        child: Container(
                                          width: 40, height: 40,
                                          decoration: BoxDecoration(
                                            color: p,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.black26),
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (color != null) {
                              setDialogState(() {
                                primaryColor = color;
                                theme = ForestSeasonTheme(
                                  treeType: theme.treeType,
                                  primaryColor: _colorToHex(color),
                                  backgroundColor: theme.backgroundColor,
                                  effect: theme.effect,
                                  backgroundImageUrl: theme.backgroundImageUrl,
                                );
                              });
                            }
                          },
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black26),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _colorToHex(primaryColor),
                              style: TextStyle(fontSize: 13, color: primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 테마: 효과
                    DropdownButtonFormField<String>(
                      initialValue: theme.effect,
                      decoration: const InputDecoration(
                        labelText: '효과',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(_effectOptions.length, (i) =>
                        DropdownMenuItem(value: _effectOptions[i], child: Text(_effectLabels[i])),
                      ),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => theme = ForestSeasonTheme(
                            treeType: theme.treeType,
                            primaryColor: _colorToHex(primaryColor),
                            backgroundColor: theme.backgroundColor,
                            effect: v,
                            backgroundImageUrl: theme.backgroundImageUrl,
                          ));
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 설명
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: '설명',
                        hintText: '시즌 설명 (선택)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // 시작일
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setDialogState(() => startDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '시작일',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            Text(_formatDate(startDate), style: const TextStyle(fontSize: 15)),
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
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final season = AdminForestSeason(
                  id: '',
                  name: nameCtrl.text.trim(),
                  seasonType: seasonType,
                  theme: theme,
                  description: descCtrl.text.trim(),
                  startDate: startDate,
                  isActive: true,
                  treeCount: 0,
                  createdAt: DateTime.now(),
                );

                Navigator.pop(ctx);
                ref.read(adminForestSeasonsProvider.notifier).createSeason(season).catchError((e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('시즌 생성 실패: $e'), backgroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    final seasonsAsync = ref.watch(adminForestSeasonsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Forest 시즌 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () => ref.read(adminForestSeasonsProvider.notifier).load(),
          ),
        ],
      ),
      body: seasonsAsync.when(
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
                  onPressed: () => ref.read(adminForestSeasonsProvider.notifier).load(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
        data: (seasons) {
          final activeSeason = seasons.where((s) => s.isActive).firstOrNull;

          return Column(
            children: [
              // 활성 시즌 카드
              if (activeSeason != null)
                _ActiveSeasonCard(
                  season: activeSeason,
                  onEnd: () => _endSeason(activeSeason.id, activeSeason.name),
                ),

              // 구분선
              if (activeSeason != null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('종료된 시즌', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),

              // 시즌 목록
              Expanded(
                child: seasons.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.forest_outlined, size: 56, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('등록된 시즌이 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: seasons.length,
                        itemBuilder: (_, i) {
                          final season = seasons[i];
                          return _SeasonListTile(
                            season: season,
                            onEnd: season.isActive
                                ? () => _endSeason(season.id, season.name)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('새 시즌'),
      ),
    );
  }
}

// ===============================================================
// 활성 시즌 카드
// ===============================================================

class _ActiveSeasonCard extends StatelessWidget {
  final AdminForestSeason season;
  final VoidCallback onEnd;

  const _ActiveSeasonCard({required this.season, required this.onEnd});

  IconData _seasonIcon(ForestSeasonType type) => switch (type) {
    ForestSeasonType.spring => Icons.local_florist,
    ForestSeasonType.summer => Icons.wb_sunny,
    ForestSeasonType.autumn => Icons.park,
    ForestSeasonType.winter => Icons.ac_unit,
  };

  String _effectLabel(String effect) => switch (effect) {
    'blossom' => '🌸 벚꽃 흩날림',
    'snow' => '❄️ 눈 내림',
    'leaf' => '🍂 낙엽',
    _ => '없음',
  };

  @override
  Widget build(BuildContext context) {
    final primaryColor = _parseHexColor(season.theme.primaryColor);
    final bgColor = _parseHexColor(season.theme.backgroundColor);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shadowColor: primaryColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '현재 활성 시즌',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: onEnd,
                    icon: const Icon(Icons.stop_circle_outlined, size: 18),
                    label: const Text('시즌 종료'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 시즌 정보
              Row(
                children: [
                  Icon(_seasonIcon(season.seasonType), size: 36, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          season.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${season.seasonTypeLabel} · ${season.theme.treeType} · ${_effectLabel(season.theme.effect)}',
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 색상 미리보기 & 상세 정보
              Row(
                children: [
                  // Primary color chip
                  Column(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('주요', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Background color chip
                  Column(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('배경', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // 시작일 & 나무 수
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '시작: ${_formatDate(season.startDate)}',
                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '나무 ${season.treeCount}그루 심음',
                          style: const TextStyle(fontSize: 13, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 설명
              if (season.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    season.description,
                    style: const TextStyle(fontSize: 13, color: Colors.white60),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// 시즌 목록 타일
// ===============================================================

class _SeasonListTile extends StatelessWidget {
  final AdminForestSeason season;
  final VoidCallback? onEnd;

  const _SeasonListTile({required this.season, this.onEnd});

  IconData _seasonIcon(ForestSeasonType type) => switch (type) {
    ForestSeasonType.spring => Icons.local_florist,
    ForestSeasonType.summer => Icons.wb_sunny,
    ForestSeasonType.autumn => Icons.park,
    ForestSeasonType.winter => Icons.ac_unit,
  };

  String _effectLabel(String effect) => switch (effect) {
    'blossom' => '🌸 벚꽃',
    'snow' => '❄️ 눈',
    'leaf' => '🍂 낙엽',
    _ => '없음',
  };

  @override
  Widget build(BuildContext context) {
    final primaryColor = _parseHexColor(season.theme.primaryColor);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // 시즌 아이콘
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_seasonIcon(season.seasonType), color: primaryColor, size: 24),
            ),
            const SizedBox(width: 12),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(season.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: season.isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          season.isActive ? '활성' : '종료됨',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: season.isActive ? Colors.green.shade700 : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${season.seasonTypeLabel} · ${season.theme.treeType} · ${_effectLabel(season.theme.effect)}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '시작: ${_formatDate(season.startDate)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (season.endDate != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '종료: ${_formatDate(season.endDate!)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        '🌳 ${season.treeCount}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 색상 미리보기 + 액션
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: _parseHexColor(season.theme.backgroundColor),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (onEnd != null)
                  OutlinedButton.icon(
                    onPressed: onEnd,
                    icon: const Icon(Icons.stop, size: 16),
                    label: const Text('종료'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                  )
                else
                  const SizedBox(
                    height: 32,
                    child: Center(
                      child: Text('종료됨', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
