import 'package:flutter/material.dart';

import '../models/family_ai_summary.dart';

/// ===============================================================
///
/// Family AI Card
///
/// AI 가족 건강 코치
///
/// HealthON Release v1
///
/// ===============================================================

class FamilyAiCard extends StatelessWidget {
  final FamilyAiSummary summary;

  final VoidCallback? onMissionPressed;

  final VoidCallback? onDetailPressed;

  const FamilyAiCard({
    super.key,
    required this.summary,
    this.onMissionPressed,
    this.onDetailPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                const CircleAvatar(
                  radius: 24,
                  child: Icon(
                    Icons.smart_toy,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "AI 가족 건강 코치",
                        style: theme.textTheme.titleLarge
                            ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        summary.healthState,
                        style: TextStyle(
                          color: _stateColor(),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                FilledButton(
                  onPressed: onDetailPressed,
                  child: const Text("리포트"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _scoreTile(),

            const SizedBox(height: 18),

            _coachMessage(),

            const SizedBox(height: 18),

            _todayMission(),

            const SizedBox(height: 18),

            _encouragement(),

          ],
        ),
      ),
    );
  }

  Widget _scoreTile() {

    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.green.shade50,

        borderRadius:
            BorderRadius.circular(18),

      ),

      child: Row(

        children: [

          Icon(

            Icons.favorite,

            color: Colors.red.shade400,

          ),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(

                  "가족 행복지수",

                ),

                const SizedBox(height: 4),

                Text(

                  summary.happinessLabel,

                  style: const TextStyle(

                    fontSize: 28,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),
              ],
            ),
          ),

          CircularProgressIndicator(

            value: summary.goalProgress,

          ),
        ],
      ),
    );
  }

  Widget _coachMessage() {

    return _section(

      icon: Icons.psychology,

      title: "오늘의 AI 분석",

      message: summary.coachMessage,

    );
  }

  Widget _todayMission() {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.orange.shade50,

        borderRadius:
            BorderRadius.circular(18),

      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Row(

            children: [

              Icon(Icons.flag),

              SizedBox(width: 8),

              Text(

                "오늘의 추천 미션",

                style: TextStyle(

                  fontWeight:
                      FontWeight.bold,

                ),

              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(

            summary.todayMission,

          ),

          const SizedBox(height: 16),

          SizedBox(

            width: double.infinity,

            child: FilledButton.icon(

              onPressed:
                  onMissionPressed,

              icon: const Icon(
                Icons.play_arrow,
              ),

              label: const Text(
                "미션 시작",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _encouragement() {

    return _section(

      icon: Icons.favorite,

      title: "AI 응원",

      message: summary.encouragement,

    );
  }

  Widget _section({

    required IconData icon,

    required String title,

    required String message,

  }) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.grey.shade100,

        borderRadius:
            BorderRadius.circular(18),

      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(icon),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

                const SizedBox(height: 8),

                Text(message),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _stateColor() {

    switch (summary.healthState) {

      case "최고":
        return Colors.green;

      case "좋음":
        return Colors.blue;

      case "보통":
        return Colors.orange;

      default:
        return Colors.red;
    }
  }
}
