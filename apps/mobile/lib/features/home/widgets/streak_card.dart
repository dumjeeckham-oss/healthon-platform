import 'package:flutter/material.dart';

import '../../../shared/widgets/info_card.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({
    super.key,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Row(
        children: [

          const Icon(
            Icons.local_fire_department,
            color: Colors.orange,
            size: 40,
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "연속 참여",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "$streakDays일째 건강 ON",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
