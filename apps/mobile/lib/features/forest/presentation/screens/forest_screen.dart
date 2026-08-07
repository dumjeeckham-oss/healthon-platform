import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../health/presentation/providers/health_provider.dart';

/// ===============================================================
/// Forest Screen — health_daily.steps 기반
/// ===============================================================

class ForestScreen extends ConsumerWidget {
  const ForestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWeek = ref.watch(healthWeekProvider);
    final asyncMonth = ref.watch(healthMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('건강숲'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(healthWeekProvider);
          ref.invalidate(healthMonthProvider);
          await ref.read(healthWeekProvider.future);
        },
        child: asyncWeek.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 250),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),
              Icon(Icons.park, size: 80, color: Colors.green.shade300),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  '숲 정보를 불러올 수 없습니다.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(e.toString(), textAlign: TextAlign.center)),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(healthWeekProvider);
                    ref.invalidate(healthMonthProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ),
            ],
          ),
          data: (weekData) {
            final (weekSteps, weekDistance, _) = weekData;
            final treeLevel = _calcTreeLevel(weekSteps);
            final nextLevelSteps = _nextLevelSteps(treeLevel);
            final currentLevelSteps = _currentLevelSteps(treeLevel);
            final levelExp = weekSteps - currentLevelSteps;
            final levelNeed = nextLevelSteps - currentLevelSteps;
            final progress = levelNeed > 0 ? (levelExp / levelNeed).clamp(0.0, 1.0) : 1.0;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                // Forest Card
                ForestCardFromHealth(
                  treeLevel: treeLevel,
                  treeName: _treeName(treeLevel),
                  totalSteps: weekSteps,
                  totalDistance: weekDistance,
                  progress: progress,
                  levelExp: levelExp,
                  levelNeed: levelNeed,
                ),

                const SizedBox(height: 24),

                // Month summary
                asyncMonth.when(
                  data: (monthData) {
                    final (mSteps, mDist, _) = monthData;
                    return _MonthSummary(steps: mSteps, distance: mDist);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // Info card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🌳 건강숲 안내', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        SizedBox(height: 20),
                        ListTile(leading: Icon(Icons.directions_walk), title: Text('걸을수록 나무가 성장합니다.')),
                        Divider(),
                        ListTile(leading: Icon(Icons.park), title: Text('누적 거리로 레벨이 상승합니다.')),
                        Divider(),
                        ListTile(leading: Icon(Icons.emoji_events), title: Text('레벨업 시 새로운 나무가 등장합니다.')),
                        Divider(),
                        ListTile(leading: Icon(Icons.groups), title: Text('가족과 함께 숲을 성장시켜보세요.')),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  int _calcTreeLevel(int steps) {
    if (steps >= 200000) return 8;
    if (steps >= 120000) return 7;
    if (steps >= 80000) return 6;
    if (steps >= 50000) return 5;
    if (steps >= 30000) return 4;
    if (steps >= 15000) return 3;
    if (steps >= 5000) return 2;
    if (steps > 0) return 1;
    return 1;
  }

  int _nextLevelSteps(int level) {
    switch (level) {
      case 1: return 5000;
      case 2: return 15000;
      case 3: return 30000;
      case 4: return 50000;
      case 5: return 80000;
      case 6: return 120000;
      case 7: return 200000;
      default: return 200000;
    }
  }

  int _currentLevelSteps(int level) {
    switch (level) {
      case 1: return 0;
      case 2: return 5000;
      case 3: return 15000;
      case 4: return 30000;
      case 5: return 50000;
      case 6: return 80000;
      case 7: return 120000;
      case 8: return 200000;
      default: return 0;
    }
  }

  String _treeName(int level) {
    switch (level) {
      case 1: return '새싹';
      case 2: return '묘목';
      case 3: return '어린나무';
      case 4: return '성장나무';
      case 5: return '큰나무';
      case 6: return '숲';
      case 7: return '울창한숲';
      case 8: return '열대우림';
      default: return '새싹';
    }
  }
}

// ===============================================================
// Forest Card (Health version)
// ===============================================================

class ForestCardFromHealth extends StatelessWidget {
  final int treeLevel;
  final String treeName;
  final int totalSteps;
  final double totalDistance;
  final double progress;
  final int levelExp;
  final int levelNeed;

  const ForestCardFromHealth({
    super.key,
    required this.treeLevel,
    required this.treeName,
    required this.totalSteps,
    required this.totalDistance,
    required this.progress,
    required this.levelExp,
    required this.levelNeed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.green.shade200),
      ),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Tree icon + level
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _treeEmoji(treeLevel),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Lv.$treeLevel $treeName',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.green.shade100,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${levelExp.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                ),
                Text(
                  '${levelNeed.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: '누적 걸음', value: totalSteps.toString()),
                _Stat(label: '누적 거리', value: '${totalDistance.toStringAsFixed(1)}km'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _treeEmoji(int level) {
    switch (level) {
      case 1: return '🌱';
      case 2: return '🌿';
      case 3: return '🪴';
      case 4: return '🌳';
      case 5: return '🌲';
      case 6: return '🏞️';
      case 7: return '🌴';
      case 8: return '🏝️';
      default: return '🌱';
    }
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _MonthSummary extends StatelessWidget {
  final int steps;
  final double distance;

  const _MonthSummary({required this.steps, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('📊', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  '이번달 통계',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.blue.shade800),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: '총 걸음', value: steps.toString()),
                _Stat(label: '총 거리', value: '${distance.toStringAsFixed(1)}km'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
