import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/step_provider.dart';

class TodayStepCard extends ConsumerWidget {
  const TodayStepCard({super.key});

  static const int goal = 10000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayStep = ref.watch(todayStepProvider);
    final distance = ref.watch(distanceProvider);
    final goalRate = ref.watch(goalRateProvider);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: todayStep.when(
          loading: () => const SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => SizedBox(
            height: 180,
            child: Center(
              child: Text(
                "걸음수를 불러오지 못했습니다.\n$e",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (steps) {
            final remain = (goal - steps).clamp(0, goal);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "오늘의 걸음",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "${steps.toString()} 걸음",
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 18),

                goalRate.when(
                  data: (rate) => Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: LinearProgressIndicator(
                          value: rate,
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${(rate * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),

                const SizedBox(height: 20),

                distance.when(
                  data: (km) => Row(
                    children: [
                      const Icon(Icons.route, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        "${km.toStringAsFixed(2)} km",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flag,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          remain == 0
                              ? "🎉 오늘 목표를 달성했습니다!"
                              : "오늘 ${remain.toString()}걸음만 더 걸으면 목표 달성입니다.",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
