import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_models.dart';
import '../admin_provider.dart';
import '../supabase_admin_repository.dart';

/// ===============================================================
/// HealthON — Forest 시즌 관리 화면
/// ===============================================================

final _treeTypes = const [
  '기본',
  '벚꽃',
  '단풍',
  '소나무',
  '열대',
  '겨울',
  '봄',
];

class AdminSeasonsScreen extends ConsumerStatefulWidget {
  const AdminSeasonsScreen({super.key});

  @override
  ConsumerState<AdminSeasonsScreen> createState() => _AdminSeasonsScreenState();
}

class _AdminSeasonsScreenState extends ConsumerState<AdminSeasonsScreen> {
  Future<void> _createSeason() async {
    final result = await showDialog<AdminForestSeason>(
      context: context,
      builder: (ctx) => const _CreateSeasonDialog(),
    );
    if (result == null) return;

    final repo = ref.read(adminRepositoryProvider);
    try {
      await repo.createForestSeason(result);
      ref.invalidate(adminForestSeasonsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('시즌 생성 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _endSeason(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('시즌 종료'),
        content: Text('"$name" 시즌을 종료하시겠습니까?'),
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

    final repo = ref.read(adminRepositoryProvider);
    try {
      await repo.endForestSeason(id);
      ref.invalidate(adminForestSeasonsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('시즌 종료 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final seasonsAsync = ref.watch(adminForestSeasonsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: seasonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('데이터를 불러오지 못했습니다.\n$err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(adminForestSeasonsProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (seasons) {
          final activeSeason = seasons.where((s) => s.isActive).firstOrNull;

          return Column(
            children: [
              // 활성 시즌 카드
              if (activeSeason != null) _ActiveSeasonCard(season: activeSeason, onEnd: () => _endSeason(activeSeason.id, activeSeason.name)),
              // 구분선
              if (activeSeason != null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('모든 시즌', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),
              // 시즌 목록
              Expanded(
                child: seasons.isEmpty
                    ? const Center(child: Text('등록된 시즌이 없습니다.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: seasons.length,
                        itemBuilder: (_, i) {
                          final season = seasons[i];
                          return _SeasonListTile(
                            season: season,
                            onEnd: season.isActive ? () => _endSeason(season.id, season.name) : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createSeason,
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

  IconData _treeIcon(String treeType) {
    switch (treeType) {
      case '벚꽃': return Icons.local_florist;
      case '단풍': return Icons.park;
      case '소나무': return Icons.nature;
      case '열대': return Icons.palm_tree;
      case '겨울': return Icons.ac_unit;
      case '봄': return Icons.eco;
      default: return Icons.forest;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF2E7D32),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('현재 활성 시즌', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: onEnd,
                    icon: const Icon(Icons.stop_circle_outlined, size: 18),
                    label: const Text('시즌 종료'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(_treeIcon(season.treeType), size: 32, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(season.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          '${season.treeType} · 시작: ${_formatDate(season.startDate)}',
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (season.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(season.description, style: const TextStyle(fontSize: 14, color: Colors.white60)),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(season.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(season.isActive ? '활성' : '종료됨', style: const TextStyle(fontSize: 12)),
                        backgroundColor: season.isActive ? const Color(0xFF4CAF50).withOpacity(0.15) : Colors.grey.shade200,
                        labelStyle: TextStyle(color: season.isActive ? const Color(0xFF2E7D32) : Colors.grey),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '나무: ${season.treeType}  ·  시작: ${_formatDate(season.startDate)}  ${season.endDate != null ? '·  종료: ${_formatDate(season.endDate!)}' : ''}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  if (season.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(season.description, style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            if (onEnd != null)
              OutlinedButton.icon(
                onPressed: onEnd,
                icon: const Icon(Icons.stop, size: 16),
                label: const Text('종료'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 새 시즌 생성 다이얼로그
// ===============================================================

class _CreateSeasonDialog extends StatefulWidget {
  const _CreateSeasonDialog();

  @override
  State<_CreateSeasonDialog> createState() => _CreateSeasonDialogState();
}

class _CreateSeasonDialogState extends State<_CreateSeasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _treeType = '기본';
  DateTime _startDate = DateTime.now();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final season = AdminForestSeason(
      id: '',
      name: _nameCtrl.text.trim(),
      treeType: _treeType,
      description: _descCtrl.text.trim(),
      startDate: _startDate,
      isActive: true,
      createdAt: DateTime.now(),
    );
    Navigator.pop(context, season);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 Forest 시즌'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: '시즌 이름', hintText: '예: 봄맞이 벚꽃 시즌'),
                validator: (v) => (v == null || v.trim().isEmpty) ? '이름을 입력하세요' : null,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _treeType,
                decoration: const InputDecoration(labelText: '나무 종류'),
                items: _treeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _treeType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: '설명', hintText: '시즌 설명 (선택)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: '시작일'),
                  child: Row(
                    children: [
                      Text(_formatDate(_startDate), style: const TextStyle(fontSize: 15)),
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
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(onPressed: _submit, child: const Text('생성')),
      ],
    );
  }
}

// ===============================================================
// Helpers
// ===============================================================

String _formatDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
