import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../social_provider.dart';

/// ===============================================================
/// HealthON — AI Recommendation Card (Home 화면용)
/// ===============================================================

class AiRecommendationCard extends ConsumerWidget {
  const AiRecommendationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(aiRecommendationsProvider);

    return recommendationsAsync.when(
      data: (result) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF2E7D32).withOpacity(0.2)),
        ),
        color: const Color(0xFFF6F8F7),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 오늘의 한마디
              _DailyMessageSection(message: result.dailyMessage),
              const SizedBox(height: 16),

              // 추천 챌린지
              if (result.challenges.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.emoji_events,
                  title: '추천 챌린지',
                ),
                ...result.challenges.take(2).map(
                      (c) => _ChallengeRow(challenge: c.name, reason: c.reason),
                    ),
                const SizedBox(height: 12),
              ],

              // 추천 친구
              if (result.friends.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.people_outline,
                  title: '함께 걸으면 좋은 사람들',
                ),
                ...result.friends.take(3).map(
                      (f) => _FriendRow(
                        name: f.userName,
                        steps: f.weeklySteps,
                        reason: f.reason,
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _DailyMessageSection extends StatelessWidget {
  final String message;

  const _DailyMessageSection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 건강ON',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  final String challenge;
  final String reason;

  const _ChallengeRow({required this.challenge, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  reason,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  final String name;
  final int steps;
  final String reason;

  const _FriendRow({required this.name, required this.steps, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  reason,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '$steps보',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
