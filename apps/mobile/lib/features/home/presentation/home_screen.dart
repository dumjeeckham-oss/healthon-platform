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
              )
            ],
          ),

          body: ListView(
            padding: const EdgeInsets.all(20),

            children: [

              Text(
                "안녕하세요 👋",
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 6),

              Text(
                user?.name ?? "회원",
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 30),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [

                      const Icon(
                        Icons.directions_walk,
                        size: 48,
                        color: Colors.green,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "오늘 걸음수",
                        style: TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "0 걸음",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text("오늘의 목표"),
                  subtitle: const Text("10,000 걸음"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.emoji_events),
                  title: const Text("챌린지"),
                  subtitle: const Text("100K 챌린지 참여중"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.groups),
                  title: const Text("가족 랭킹"),
                  subtitle: const Text("이번 주 순위 보기"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.psychology),
                  title: const Text("AI 건강코치"),
                  subtitle: const Text("오늘의 건강 메시지"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),

              const SizedBox(height: 30),

              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("걸음수 동기화"),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}