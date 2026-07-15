import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/walking_provider.dart';

import '../providers/today_steps_provider.dart';

class TodayStepCard extends ConsumerWidget {
  const TodayStepCard({super.key});

  static const int dailyGoal = 10000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepsAsync = ref.watch(todayStepsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: stepsAsync.when(
          loading: () => const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),

          error: (error, stack) => SizedBox(
            height: 150,
            child: Center(
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          data: (steps) {
            final percent =
                (steps / dailyGoal).clamp(0.0, 1.0);

            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                //--------------------------------------------------
                // 제목
                //--------------------------------------------------

                const Row(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "오늘 걸음수",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                //--------------------------------------------------
                // 걸음수
                //--------------------------------------------------

                Center(
                  child: Text(
                    "${steps.toString()} 걸음",
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //--------------------------------------------------
                // Progress
                //--------------------------------------------------

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 14,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    const Text(
                      "목표 10,000걸음",
                    ),

                    Text(
                      "${(percent * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                //--------------------------------------------------
                // 새로고침
                //--------------------------------------------------

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.sync),
                    label: const Text("Health Connect 동기화"),
                    onPressed: () {
                      ref.invalidate(todayStepsProvider);
                    },
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
