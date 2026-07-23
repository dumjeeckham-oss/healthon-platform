import 'package:flutter/material.dart';

import '../../domain/models/forest_species.dart';

class ForestSpeciesDetailScreen extends StatelessWidget {
  final ForestSpecies species;

  const ForestSpeciesDetailScreen({
    super.key,
    required this.species,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(species.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            Text(
              species.emoji,
              style: const TextStyle(
                fontSize: 120,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              species.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              species.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Lv.${species.level}",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
