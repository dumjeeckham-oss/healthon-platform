import 'package:flutter/material.dart';

import '../widgets/challenge_progress_card.dart';
import '../widgets/welcome_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7FAF7),

      appBar: AppBar(
        title: const Text("건강ON"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            const WelcomeCard(
              userName: "홍길동",
              challengeName: "생활 속 100K 걷기",
            ),

            const SizedBox(height: 16),

            ChallengeProgressCard(
              challengeName: "생활 속 100K 걷기",
              currentKm: 38.4,
              goalKm: 100,
              endDate: DateTime(2026, 12, 31),
            ),

            const SizedBox(height: 16),

            _buildComingSoonCard(
              icon: Icons.directions_walk,
              title: "오늘 걸음",
              subtitle: "다음 단계에서 구현됩니다.",
            ),

            const SizedBox(height: 16),

            _buildComingSoonCard(
              icon: Icons.local_fire_department,
              title: "연속 참여",
              subtitle: "다음 단계에서 구현됩니다.",
            ),

            const SizedBox(height: 16),

            _buildComingSoonCard(
              icon: Icons.park,
              title: "건강숲",
              subtitle: "다음 단계에서 구현됩니다.",
            ),

            const SizedBox(height: 16),

            _buildComingSoonCard(
              icon: Icons.workspace_premium,
              title: "배지",
              subtitle: "다음 단계에서 구현됩니다.",
            ),

            const SizedBox(height: 16),

            _buildComingSoonCard(
              icon: Icons.favorite,
              title: "오늘의 응원",
              subtitle: "다음 단계에서 구현됩니다.",
            ),

            const SizedBox(height: 16),

            _buildComingSoonCard(
              icon: Icons.leaderboard,
              title: "랭킹",
              subtitle: "다음 단계에서 구현됩니다.",
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(
            icon,
            color: Colors.green,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
