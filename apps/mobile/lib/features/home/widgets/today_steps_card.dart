import 'package:flutter/material.dart';

import '../../../shared/widgets/info_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../walking/presentation/providers/walking_provider.dart';

class TodayStepsCard extends StatelessWidget {
  final int steps;
  final int goalSteps;

  const TodayStepsCard({
    super.key,
    required this.steps,
    this.goalSteps = 8000,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (steps / goalSteps).clamp(0.0, 1.0);

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "👣 오늘 걸음",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: ProgressRing(
              progress: progress,
              size: 140,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    "$steps",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    "걸음",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "목표 $goalSteps걸음 중 ${(progress * 100).toStringAsFixed(0)}% 달성",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
