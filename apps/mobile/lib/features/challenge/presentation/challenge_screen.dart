import 'package:flutter/material.dart';

import 'widgets/challenge_progress_section.dart';
import 'widgets/team_cheer_card.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("100K 챌린지"),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 700));
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [

            Text(
              "현재 진행중인 챌린지",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "오늘도 목표를 향해 함께 걸어요 👣",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            SizedBox(height: 28),

            ChallengeProgressSection(),

            SizedBox(height: 24),

            TeamCheerCard(),

            SizedBox(height: 24),

            _ChallengeStatistics(),

            SizedBox(height: 24),

            _RecentFinishUsers(),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ChallengeStatistics extends StatelessWidget {
  const _ChallengeStatistics();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [

            Row(
              children: [

                Expanded(
                  child: _StatItem(
                    title: "참여자",
                    value: "248",
                  ),
                ),

                Expanded(
                  child: _StatItem(
                    title: "완주",
                    value: "83",
                  ),
                ),

                Expanded(
                  child: _StatItem(
                    title: "진행중",
                    value: "165",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),

        const SizedBox(height: 6),

        Text(title),
      ],
    );
  }
}

class _RecentFinishUsers extends StatelessWidget {
  const _RecentFinishUsers();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "최근 완주자",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16),

            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.emoji_events),
              ),
              title: Text("김광민"),
              subtitle: Text("100K 완주 🎉"),
            ),

            Divider(),

            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.emoji_events),
              ),
              title: Text("이영희"),
              subtitle: Text("50K 달성"),
            ),

            Divider(),

            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.emoji_events),
              ),
              title: Text("홍길동"),
              subtitle: Text("200K 완주"),
            ),
          ],
        ),
      ),
    );
  }
}
