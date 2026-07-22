import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forest_provider.dart';
import '../widgets/forest_card.dart';

class ForestScreen extends ConsumerWidget {
  const ForestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forest = ref.watch(forestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("나의 숲"),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(forestProvider);
          await ref.read(forestProvider.future);
        },
        child: forest.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 120),
              Icon(
                Icons.park_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "숲 정보를 불러오지 못했습니다.",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(forestProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("다시 시도"),
                ),
              ),
            ],
          ),
          data: (summary) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                ForestCard(summary: summary),

                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "성장 안내",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const ListTile(
                          leading: Icon(
                            Icons.directions_walk,
                            color: Colors.green,
                          ),
                          title: Text("걸으면 나무가 성장합니다."),
                        ),

                        const Divider(),

                        const ListTile(
                          leading: Icon(
                            Icons.forest,
                            color: Colors.green,
                          ),
                          title: Text("100km마다 숲이 더욱 풍성해집니다."),
                        ),

                        const Divider(),

                        const ListTile(
                          leading: Icon(
                            Icons.emoji_events,
                            color: Colors.orange,
                          ),
                          title: Text("가족과 함께 더 큰 숲을 만들어보세요."),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }
}
