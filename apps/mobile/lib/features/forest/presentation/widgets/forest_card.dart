import 'package:flutter/material.dart';

import '../../domain/models/forest_summary.dart';
import '../../domain/models/tree_level.dart';

class ForestCard extends StatelessWidget {
  final ForestSummary summary;

  const ForestCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final level = TreeLevel.fromLevel(summary.treeLevel);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('내 건강숲',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Center(child: Text(level.emoji, style: const TextStyle(fontSize: 64))),
            const SizedBox(height: 16),
            Center(child: Text(level.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(value: summary.progress, minHeight: 14),
            ),
            const SizedBox(height: 10),
            Text('누적 ${summary.totalKm.toStringAsFixed(1)} km'),
            const SizedBox(height: 8),
            Text('Lv.${summary.treeLevel}'),
          ],
        ),
      ),
    );
  }
}
