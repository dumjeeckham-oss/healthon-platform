import 'package:flutter/material.dart';

import '../domain/models/family_member_ranking.dart';

/// ===============================================================
///
/// Family Summary Card
///
/// 가족 현황 요약 카드
///
/// HealthON Release v1
///
/// ===============================================================

class FamilySummaryCard extends StatelessWidget {
  final List<FamilyMemberRanking> members;

  const FamilySummaryCard({
    super.key,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalSteps = members.fold<int>(
      0,
      (sum, member) => sum + member.steps,
    );

    final leader = members.isEmpty
        ? null
        : ([...members]..sort(
            (a, b) => b.steps.compareTo(a.steps),
          ));

    final leaderMember = leader?.first;

    final goalSteps = members.length * 10000;

    final progress =
        goalSteps == 0 ? 0.0 : totalSteps / goalSteps;

    final healthScore =
        (progress * 100).clamp(0.0, 100.0);

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

                const Text(
                  "❤️",
                  style: TextStyle(fontSize: 26),
                ),

                const SizedBox(width: 8),

                Text(
                  "가족 행복지수",
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),

            const SizedBox(height: 18),

            Center(
              child: Column(
                children: [

                  Text(
                    "${healthScore.toInt()}점",
                    style: theme
                        .textTheme
                        .displaySmall
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.red,
                        ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _healthMessage(
                      healthScore,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              borderRadius:
                  BorderRadius.circular(20),
            ),

            const SizedBox(height: 22),

            Row(
              children: [

                Expanded(
                  child: _infoCard(
                    icon: Icons.groups,
                    title: "참여",
                    value:
                        "${members.length}명",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _infoCard(
                    icon:
                        Icons.directions_walk,
                    title: "총 걸음",
                    value:
                        _format(totalSteps),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: _infoCard(
                    icon:
                        Icons.emoji_events,
                    title: "오늘 1등",
                    value:
                        leaderMember?.name ??
                            "-",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _infoCard(
                    icon: Icons.flag,
                    title: "목표",
                    value:
                        "${(progress * 100).toStringAsFixed(0)}%",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Icon(
                    Icons.smart_toy,
                    color: Colors.blue,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      _aiComment(
                        progress,
                      ),
                      style:
                          theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          Icon(icon),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  String _healthMessage(
    double score,
  ) {
    if (score >= 90) {
      return "오늘도 정말 건강한 하루를 보내고 있어요!";
    }

    if (score >= 70) {
      return "조금만 더 걸으면 최고 점수예요.";
    }

    if (score >= 50) {
      return "가족과 함께 산책하면 점수가 크게 올라갑니다.";
    }

    return "오늘은 가족과 20분 산책을 추천합니다.";
  }

  String _aiComment(
    double progress,
  ) {
    if (progress >= 1) {
      return "🎉 오늘 가족 목표를 모두 달성했습니다! 서로를 응원하며 이 기록을 계속 이어가 보세요.";
    }

    if (progress >= 0.8) {
      return "👍 목표까지 조금 남았습니다. 저녁 산책을 함께하면 충분히 달성할 수 있어요.";
    }

    if (progress >= 0.5) {
      return "🚶 지금까지 좋은 흐름입니다. 가족 한 명이 20분만 더 걸어도 큰 차이를 만들 수 있습니다.";
    }

    return "💡 오늘은 가족 모두가 함께 가까운 공원이나 동네를 걸어보는 건 어떨까요?";
  }

  String _format(
    int value,
  ) {
    final text = value.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      final position =
          text.length - i - 1;

      if (position > 0 &&
          position % 3 == 0) {
        buffer.write(",");
      }
    }

    return buffer.toString();
  }
}
