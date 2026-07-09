import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/challenge_provider.dart';

class ChallengeProgressSection extends ConsumerWidget {
  const ChallengeProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(challengeProvider);

    return progressAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (progress) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "100K 챌린지",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StageChip(
                      title: "50K",
                      completed: progress.completed50K,
                    ),
                    _StageChip(
                      title: "100K",
                      completed: progress.completed100K,
                    ),
                    _StageChip(
                      title: "200K",
                      completed: progress.completed200K,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Text(
                  "${progress.totalSteps.toString()} 걸음",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "현재 목표 : ${progress.currentGoal.toString()} 걸음",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress.progress,
                    minHeight: 14,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${(progress.progress * 100).toStringAsFixed(1)}%",
                    ),
                    Text(
                      "${progress.remainSteps} 걸음 남음",
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(challengeProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("챌린지 새로고침"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StageChip extends StatelessWidget {
  final String title;
  final bool completed;

  const _StageChip({
    required this.title,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        completed ? Icons.check_circle : Icons.flag,
        color: completed ? Colors.green : Colors.grey,
        size: 18,
      ),
      label: Text(title),
      backgroundColor:
          completed ? Colors.green.shade50 : Colors.grey.shade100,
    );
  }
}
