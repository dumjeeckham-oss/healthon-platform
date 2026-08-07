import 'package:flutter/material.dart';

/// ===============================================================
/// HealthON — Achievement Cards
///
/// Challenge 완료 / Forest 성장 / 랭킹 상승 / Badge 획득
/// SNS 공유용 자동 카드 위젯
/// ===============================================================

// ===============================================================
// Achievement Card (범용)
// ===============================================================

class AchievementCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? detail;
  final Color color;
  final VoidCallback? onShare;

  const AchievementCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.detail,
    this.color = const Color(0xFF2E7D32),
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      color: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (onShare != null)
                  GestureDetector(
                    onTap: onShare,
                    child: Icon(Icons.share_outlined, size: 20, color: color),
                  ),
              ],
            ),
            if (detail != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  detail!,
                  style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// Ranking Card
// ===============================================================

class RankingCard extends StatelessWidget {
  final int rank;
  final int previousRank;
  final String scope;
  final int totalSteps;

  const RankingCard({
    super.key,
    required this.rank,
    required this.previousRank,
    required this.scope,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final bool improved = rank < previousRank;
    final String medalEmoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '🏅';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.amber.shade300),
      ),
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(medalEmoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$scope랭킹 $rank위',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    if (improved)
                      Text(
                        '⬆️ $previousRank위 → $rank위 상승!',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${totalSteps.toString().replaceAllMapped(
                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
              )} 보',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// Forest Card
// ===============================================================

class ForestAchievementCard extends StatelessWidget {
  final int level;
  final String treeName;
  final int totalSteps;

  const ForestAchievementCard({
    super.key,
    required this.level,
    required this.treeName,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = _treeEmoji(level);

    return AchievementCard(
      icon: emoji,
      title: 'Forest Lv.$level $treeName',
      subtitle: '$totalSteps보 달성!',
      detail: '걸을수록 건강한 숲이 자랍니다 🌱',
      color: Colors.green.shade700,
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

// ===============================================================
// Challenge Card
// ===============================================================

class ChallengeAchievementCard extends StatelessWidget {
  final String challengeName;
  final double totalKm;
  final double progress;
  final bool completed;

  const ChallengeAchievementCard({
    super.key,
    required this.challengeName,
    required this.totalKm,
    required this.progress,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return AchievementCard(
        icon: '🏆',
        title: '$challengeName 완료!',
        subtitle: '${totalKm.toStringAsFixed(1)}km 달성',
        detail: '🎉 축하합니다! 대단한 성과입니다!',
        color: Colors.orange.shade700,
      );
    }

    return AchievementCard(
      icon: '🔥',
      title: challengeName,
      subtitle: '${(progress * 100).round()}% 진행중',
      detail: '${totalKm.toStringAsFixed(1)}km 걸었습니다. 계속 화이팅!',
      color: Colors.orange.shade500,
    );
  }
}

// ===============================================================
// Badge Card
// ===============================================================

class BadgeAchievementCard extends StatelessWidget {
  final String badgeTitle;
  final String badgeIcon;

  const BadgeAchievementCard({
    super.key,
    required this.badgeTitle,
    required this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AchievementCard(
      icon: badgeIcon,
      title: '새로운 뱃지 획득!',
      subtitle: '"$badgeTitle"',
      detail: '프로필에서 확인해보세요 ✨',
      color: Colors.purple.shade700,
    );
  }
}

// ===============================================================
// Walk Milestone Card
// ===============================================================

class WalkMilestoneCard extends StatelessWidget {
  final int steps;
  final double distanceKm;
  final double calories;

  const WalkMilestoneCard({
    super.key,
    required this.steps,
    required this.distanceKm,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return AchievementCard(
      icon: '🚶',
      title: '오늘 ${stepsToString(steps)}보',
      subtitle: '${distanceKm.toStringAsFixed(1)}km · ${calories.round()}kcal',
      detail: '오늘도 목표를 향해 함께 걸어요!',
      color: const Color(0xFF2E7D32),
    );
  }

  String stepsToString(int steps) {
    return steps.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
