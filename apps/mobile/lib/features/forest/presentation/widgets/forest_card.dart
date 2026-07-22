import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forest_provider.dart';

class ForestCard extends ConsumerWidget {
  const ForestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forestAsync = ref.watch(forestProvider);

    return forestAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),

      error: (e, s) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(e.toString()),
        ),
      ),

      data: (forest) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
                  "내 건강숲",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: TreeAnimation(
                    level: summary.treeLevel,
                   ),
                 ),

                const SizedBox(height: 16),

                Text(
                  forest.treeName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                LinearProgressIndicator(
                  value: forest.progress,
                  minHeight: 12,
                ),

                const SizedBox(height: 10),

                Text(
                  "${forest.treeExp.toStringAsFixed(1)} / ${forest.nextLevelExp.toStringAsFixed(1)} km",
                ),

                const SizedBox(height: 8),

                Text(
                  "누적 ${forest.totalKm.toStringAsFixed(1)} km",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _treeEmoji(int level) {
    if (level >= 20) return "🌲";
    if (level >= 10) return "🌳";
    if (level >= 5) return "🌴";
    if (level >= 3) return "🌿";
    if (level >= 2) return "🌱";
    return "🌱";
  }
}
