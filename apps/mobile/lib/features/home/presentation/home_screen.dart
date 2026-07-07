import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/provider/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),

      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: const Text('건강ON'),
        ),
        body: Center(
          child: Text(
            e.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      ),

      data: (user) {
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

          body: RefreshIndicator(
            onRefresh: () async {
              await ref.read(authProvider.notifier).refreshUser();
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  "안녕하세요 👋",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  user?.name ?? "사용자",
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 30),

                _infoCard(
                  icon: Icons.directions_walk,
                  title: "오늘 걸음수",
                  value: "0 걸음",
                ),

                const SizedBox(height: 16),

                _infoCard(
                  icon: Icons.route,
                  title: "누적 거리",
                  value: "0.0 km",
                ),

                const SizedBox(height: 16),

                _infoCard(
                  icon: Icons.emoji_events,
                  title: "현재 챌린지",
                  value: "부천100K",
                ),

                const SizedBox(height: 30),

                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("오늘 챌린지 시작"),
                ),

                const SizedBox(height: 20),

                const Text(
                  "AI 건강 코치",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "오늘도 10분만 더 걸어보세요.\n목표까지 조금만 남았습니다 😊",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.green,
          size: 34,
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}