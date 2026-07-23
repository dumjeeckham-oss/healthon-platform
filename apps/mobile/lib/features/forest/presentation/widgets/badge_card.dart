import 'package:flutter/material.dart';

import '../../domain/models/forest_badge.dart';

class BadgeCard extends StatelessWidget {
  final ForestBadge badge;

  const BadgeCard({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: badge.unlocked
          ? Colors.white
          : Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              badge.icon,
              style: const TextStyle(fontSize: 42),
            ),

            const SizedBox(height: 12),

            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
