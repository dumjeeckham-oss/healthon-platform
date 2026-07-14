import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/challenge_provider.dart';
import '../../domain/models/challenge_summary.dart';

class ChallengeProgressSection extends ConsumerWidget {
  const ChallengeProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(challengeProvider);

    return challengeAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(30),
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
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),

      data: (challenge) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //--------------------------------------------------
                // 제목
                //--------------------------------------------------

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
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                //--------------------------------------------------
                // 단계
                //--------------------------------------------------

                Wrap(
                   spacing: 12,
                   runSpacing: 12,
                   children: [

                      _StageChip(
                        title: "50K",
                        completed: challenge.currentKm >= 50,
                    ),

                   _StageChip(
                     title: "100K",
                     completed: challenge.currentKm >= 100,
                   ),

                  _StageChip(
                    title: "200K",
                     completed: challenge.currentKm >= 200,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                //--------------------------------------------------
                // 현재 걸음수
                //--------------------------------------------------

                Text(
                  "${challenge.currentKm.toStringAsFixed(1)} km",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "오늘 목표 : ${challenge.todayGoal.toStringAsFixed(1)} km",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                //--------------------------------------------------
                // Progress
                //--------------------------------------------------

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: challenge.progress,
                    minHeight: 14,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      "${(challenge.progress * 100).toStringAsFixed(1)} %",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "남은 거리 ${challenge.remainingKm.toStringAsFixed(1)} km",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                   Text(
                  "예상 완료일 : ${challenge.expectedFinish}",
                 ),

                const SizedBox(height: 12),

              Container(
               width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                 ),
             child: Text(
             challenge.cheerMessage,
             style: const TextStyle(
              fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 24),

                const SizedBox(height: 28),

                //--------------------------------------------------
                // 새로고침
                //--------------------------------------------------

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
        completed
            ? Icons.check_circle
            : Icons.flag,
        color: completed
            ? Colors.green
            : Colors.grey,
        size: 18,
      ),
      label: Text(title),
      backgroundColor: completed
          ? Colors.green.shade50
          : Colors.grey.shade200,
    );
  }
}
