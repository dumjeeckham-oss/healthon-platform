import 'package:flutter/material.dart';

import '../../domain/models/forest_species.dart';

class ForestSpeciesCard extends StatelessWidget {
  final ForestSpecies species;

  const ForestSpeciesCard({
    super.key,
    required this.species,
  });

  @override
  Widget build(BuildContext context) {
    final color = species.isUnlocked
        ? Colors.green.shade50
        : Colors.grey.shade200;

    return Card(
      elevation: species.isUnlocked ? 3 : 1,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              species.isUnlocked
                  ? species.emoji
                  : "❓",
              style: const TextStyle(
                fontSize: 54,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              species.isUnlocked
                  ? species.name
                  : "???",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Lv.${species.level}",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              species.isUnlocked
                  ? "획득 완료"
                  : "잠겨있음",
              style: TextStyle(
                color: species.isUnlocked
                    ? Colors.green
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
