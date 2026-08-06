import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../health/presentation/providers/health_provider.dart';
import '../../../../shared/widgets/info_card.dart';

/// ===============================================================
/// Forest Card — health_daily 기반 Forest 진행
/// ===============================================================

class ForestCard extends ConsumerWidget {
  const ForestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWeek = ref.watch(healthWeekProvider);

    return asyncWeek.when(
      loading: () => const _Skeleton(),
      error: (_, __) => const _ErrorMsg(),
      data: (data) {
        final (totalSteps, totalDistance, _) = data;
        final totalKm = totalDistance.round();
        final treeCount = _calcTreeCount(totalSteps);

        return InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌳 건강숲',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('누적 거리'),
                      Text(
                        '${totalKm}km',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('나무'),
                      Text(
                        '$treeCount그루',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '걸을수록 건강한 숲이 자랍니다 🌱',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  int _calcTreeCount(int totalSteps) {
    if (totalSteps >= 200000) return 8;
    if (totalSteps >= 120000) return 7;
    if (totalSteps >= 80000) return 6;
    if (totalSteps >= 50000) return 5;
    if (totalSteps >= 30000) return 4;
    if (totalSteps >= 15000) return 3;
    if (totalSteps >= 5000) return 2;
    if (totalSteps > 0) return 1;
    return 0;
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green.shade400),
          ),
        ),
      ),
    );
  }
}

class _ErrorMsg extends StatelessWidget {
  const _ErrorMsg();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Forest 데이터를 불러올 수 없습니다',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}
