import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forest_provider.dart';
import '../../domain/models/tree_level.dart';

class ForestCard extends StatelessWidget {
  const ForestCard({
  super.key,
  required this.summary,
});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ForestSummary summary;

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
        final level = TreeLevel.fromLevel(summary.treeLevel);

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
                   child:  TreeAnimation(
                      level: forest.treeLevel,
                 ),
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
                    value: summary.progress,
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
                      "누적 ${summary.totalKm.toStringAsFixed(1)} km",
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
                      "Lv.${summary.treeLevel}",
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
