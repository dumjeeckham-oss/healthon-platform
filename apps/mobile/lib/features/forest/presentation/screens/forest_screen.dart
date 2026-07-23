import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forest_provider.dart';
import '../widgets/forest_card.dart';

class ForestScreen extends ConsumerWidget {
  const ForestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forestAsync = ref.watch(forestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("건강숲"),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(forestProvider);
          await ref.read(forestProvider.future);
        },
        child: forestAsync.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 250),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),

          error: (e, s) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),

              Icon(
                Icons.park,
                size: 80,
                color: Colors.green.shade300,
              ),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  "숲 정보를 불러올 수 없습니다.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

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

                ForestCard(
                  summary: summary,
                ),

                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "🌳 건강숲 안내",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        SizedBox(height: 20),

                        ListTile(
                          leading: Icon(Icons.directions_walk),
                          title: Text("걸을수록 나무가 성장합니다."),
                        ),

                        Divider(),

                        ListTile(
                          leading: Icon(Icons.park),
                          title: Text("누적 거리로 레벨이 상승합니다."),
                        ),

                        Divider(),

                        ListTile(
                          leading: Icon(Icons.emoji_events),
                          title: Text("레벨업 시 새로운 나무가 등장합니다."),
                        ),

                        Divider(),

                        ListTile(
                          leading: Icon(Icons.groups),
                          title: Text("가족과 함께 숲을 성장시켜보세요."),
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
