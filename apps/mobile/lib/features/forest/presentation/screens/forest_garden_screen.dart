import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forest_garden_provider.dart';
import '../widgets/garden_tile.dart';

class ForestGardenScreen extends ConsumerWidget {
  const ForestGardenScreen({super.key});

  static const int gridSize = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO : 실제 로그인 Provider로 교체
    const userId = "CURRENT_USER";

    final garden = ref.watch(
      forestGardenProvider(userId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("내 숲"),
        centerTitle: false,
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            forestGardenProvider(userId),
          );
        },

        child: garden.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),

          error: (e, s) => ListView(
            children: [
              const SizedBox(height: 180),
              const Icon(
                Icons.park,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  e.toString(),
                ),
              ),
            ],
          ),

          data: (tiles) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [

                const Text(
                  "Forest Garden",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "나무를 심고 성장시키세요 🌳",
                ),

                const SizedBox(height: 24),

                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: gridSize * gridSize,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),

                  itemBuilder: (_, index) {

                    final x = index % gridSize;

                    final y = index ~/ gridSize;

                    final tile = tiles.firstWhere(
                      (e) =>
                          e.x == x &&
                          e.y == y,
                    );

                    return GardenTile(
                      tile: tile,

                      onTap: () {
                        if (!tile.unlocked) return;

                        if (!tile.planted) {
                          _showPlantDialog(
                            context,
                            tile,
                          );
                        } else {
                          _showTreeDialog(
                            context,
                            tile,
                          );
                        }
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: const [

                        ListTile(
                          leading: Icon(Icons.lock),
                          title: Text("회색 = 잠긴 땅"),
                        ),

                        Divider(),

                        ListTile(
                          leading: Icon(Icons.add_circle),
                          title: Text("초록 = 심을 수 있는 땅"),
                        ),

                        Divider(),

                        ListTile(
                          leading: Icon(Icons.park),
                          title: Text("나무 = 성장 중"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  //------------------------------------------------------------
  // 심기
  //------------------------------------------------------------

  void _showPlantDialog(
    BuildContext context,
    dynamic tile,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("나무 심기"),

          content: const Text(
            "이 위치에 새로운 나무를 심으시겠습니까?",
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("취소"),
            ),

            FilledButton(
              onPressed: () {

                // TODO
                Navigator.pop(context);

              },
              child: const Text("심기"),
            ),
          ],
        );
      },
    );
  }

  //------------------------------------------------------------
  // 상세
  //------------------------------------------------------------

  void _showTreeDialog(
    BuildContext context,
    dynamic tile,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("나무 정보"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                tile.objectId ?? "",
              ),

              const SizedBox(height: 20),

              Text(
                "Lv.${tile.level}",
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: tile.progress,
              ),
            ],
          ),

          actions: [

            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("닫기"),
            ),
          ],
        );
      },
    );
  }
}
