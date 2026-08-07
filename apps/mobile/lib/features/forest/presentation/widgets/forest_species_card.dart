import 'package:flutter/material.dart';

import '../../domain/models/forest_species.dart';

class ForestSpeciesCard extends StatelessWidget {
  final ForestSpecies species;

  const ForestSpeciesCard({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(species.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(species.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(species.description ?? '', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
