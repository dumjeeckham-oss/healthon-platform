import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/provider/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("건강ON"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "안녕하세요 👋",
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 6),

            Text(
              user?.name ?? "건강ON 회원",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 30),

            _buildStepCard(),

            const SizedBox(height: 20),

            _buildDistanceCard(),

            const SizedBox(height: 20),

            _buildChallengeCard(),

            const SizedBox(height: 20),

            _buildRankingCard(),

            const SizedBox(height: 20),

            _buildAiCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            Icon(Icons.directions_walk,
                size: 50, color: Colors.green),
            SizedBox(height: 10),
            Text(
              "오늘 걸음수",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "6,420",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.route),
        title: const Text("오늘 이동거리"),
        subtitle: const Text("4.8 km"),
      ),
    );
  }

  Widget _buildChallengeCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.flag),
        title: const Text("100K 챌린지"),
        subtitle: const Text("현재 42km 달성"),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildRankingCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.emoji_events),
        title: const Text("이번주 순위"),
        subtitle: const Text("전체 18위"),
      ),
    );
  }

  Widget _buildAiCard() {
    return Card(
      color: Colors.green.shade50,
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.green,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              "AI 건강코치",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "오늘은 평소보다 조금 적게 걸었어요.\n"
              "10분만 더 걸으면 목표를 달성할 수 있습니다.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}