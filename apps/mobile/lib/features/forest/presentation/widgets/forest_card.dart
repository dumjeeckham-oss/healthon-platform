import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forest_provider.dart';
import '../../domain/models/tree_level.dart';

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

      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(error.toString()),
        ),
      ),

      data: (forest) {
        final level = TreeLevel.fromLevel(forest.treeLevel);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "내 건강숲",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    level.emoji,
                    style: const TextStyle(
                      fontSize: 90,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    level.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: forest.progress,
                    minHeight: 14,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "${forest.treeExp.toStringAsFixed(1)} / ${forest.nextLevelExp.toStringAsFixed(1)} km",
                  style: const TextStyle(fontSize: 15),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(
                      Icons.route,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "누적 ${forest.totalKm.toStringAsFixed(1)} km",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.park,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Lv.${forest.treeLevel}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
