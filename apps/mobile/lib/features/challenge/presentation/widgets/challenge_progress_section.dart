import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/challenge_provider.dart';

class ChallengeProgressSection extends ConsumerWidget {
  const ChallengeProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(challengeProvider);

    return progress.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),

      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "챌린지 정보를 불러오지 못했습니다.\n$e",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),

      data: (challenge) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "100K 챌린지",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _ChallengeCard(
              title: "50K 챌린지",
              goal: 50000,
              current: challenge.totalSteps,
              progress: challenge.progress50,
              completed: challenge.completed50K,
              color: Colors.orange,
            ),

            const SizedBox(height: 14),

            _ChallengeCard(
              title: "100K 챌린지",
              goal: 100000,
              current: challenge.totalSteps,
              progress: challenge.progress100,
              completed: challenge.completed100K,
              color: Colors.green,
            ),

            const SizedBox(height: 14),

            _ChallengeCard(
              title: "200K 챌린지",
              goal: 200000,
              current: challenge.totalSteps,
              progress: challenge.progress200,
              completed: challenge.completed200K,
              color: Colors.blue,
            ),
          ],
        );
      },
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final int goal;
  final int current;
  final double progress;
  final bool completed;
  final Color color;

  const _ChallengeCard({
    required this.title,
    required this.goal,
    required this.current,
    required this.progress,
    required this.completed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final remain = (goal - current).clamp(0, goal);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            Row(
              children: [

                Icon(
                  completed
                      ? Icons.emoji_events
                      : Icons.flag,
                  color: color,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                if (completed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "완료",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius:
                  BorderRadius.circular(20),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  "${current.toString()} 걸음",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "$goal 걸음",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                completed
                    ? "🎉 챌린지를 완료했습니다!"
                    : "$remain 걸음 남았습니다.",
                style: TextStyle(
                  color: completed
                      ? Colors.green
                      : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
