import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../health/presentation/providers/health_provider.dart';

/// ===============================================================
/// Challenge Screen — health_daily.distance_km 기반
/// ===============================================================

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWeek = ref.watch(healthWeekProvider);
    final asyncMonth = ref.watch(healthMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('100K 챌린지'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(healthWeekProvider);
          ref.invalidate(healthMonthProvider);
          // Sync 실행
          await ref.read(healthSyncProvider.notifier).sync();
        },
        child: asyncMonth.when(
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
              Center(child: Text('챌린지 데이터를 불러올 수 없습니다')),
              const SizedBox(height: 12),
              Center(child: Text(e.toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
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
          data: (monthData) {
            final (monthSteps, monthDistance, _) = monthData;
            final goalKm = 100.0;
            final progress = (monthDistance / goalKm).clamp(0.0, 1.0);
            final remain = (goalKm - monthDistance).clamp(0.0, goalKm);
            final todayGoal = 3.0;
            final remainDays = todayGoal > 0 ? (remain / todayGoal).ceil() : 0;

            String cheer;
            if (progress >= 1.0) cheer = '🎉 100K 완주를 축하합니다!';
            else if (progress >= 0.8) cheer = '🔥 완주가 눈앞입니다!';
            else if (progress >= 0.5) cheer = '👏 절반을 넘었습니다!';
            else if (progress >= 0.2) cheer = '💪 좋은 페이스입니다!';
            else cheer = '🚶 첫걸음을 응원합니다!';

            final expectedDate = DateTime.now().add(Duration(days: remainDays));
            final expectedStr = '${expectedDate.year}-${expectedDate.month.toString().padLeft(2, '0')}-${expectedDate.day.toString().padLeft(2, '0')}';

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  '현재 진행중인 챌린지',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '오늘도 목표를 향해 함께 걸어요 👣',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(height: 28),

                // Main progress card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.emoji_events, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('100K 챌린지', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Stage chips
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _StageChip(title: '50K', completed: monthDistance >= 50),
                            _StageChip(title: '100K', completed: monthDistance >= 100),
                            _StageChip(title: '200K', completed: monthDistance >= 200),
                          ],
                        ),
                        const SizedBox(height: 28),

                        Text(
                          '${monthDistance.toStringAsFixed(1)} km',
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '오늘 목표 : ${todayGoal.toStringAsFixed(1)} km',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(value: progress, minHeight: 14),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${(progress * 100).toStringAsFixed(1)} %', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('남은 거리 ${remain.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text('예상 완료일 : $expectedStr'),
                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(cheer, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              ref.invalidate(healthMonthProvider);
                              ref.read(healthSyncProvider.notifier).sync();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('챌린지 새로고침'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Week stats
                asyncWeek.when(
                  data: (w) {
                    final (wSteps, wDist, _) = w;
                    return _QuickStats(weekSteps: wSteps, weekDist: wDist, monthSteps: monthSteps, monthDist: monthDistance);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  final String title;
  final bool completed;

  const _StageChip({required this.title, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        completed ? Icons.check_circle : Icons.flag,
        color: completed ? Colors.green : Colors.grey,
        size: 18,
      ),
      label: Text(title),
      backgroundColor: completed ? Colors.green.shade50 : Colors.grey.shade200,
    );
  }
}

class _QuickStats extends StatelessWidget {
  final int weekSteps;
  final double weekDist;
  final int monthSteps;
  final double monthDist;

  const _QuickStats({
    required this.weekSteps,
    required this.weekDist,
    required this.monthSteps,
    required this.monthDist,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 통계', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatItem(title: '이번주 걸음', value: weekSteps.toString()),
                ),
                Expanded(
                  child: _StatItem(title: '이번주 거리', value: '${weekDist.toStringAsFixed(1)}km'),
                ),
                Expanded(
                  child: _StatItem(title: '이번달 걸음', value: monthSteps.toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
