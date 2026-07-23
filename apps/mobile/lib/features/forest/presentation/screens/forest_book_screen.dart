import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/forest_species_repository.dart';
import '../../domain/models/forest_species.dart';
import '../widgets/forest_species_card.dart';

final forestSpeciesProvider =
    FutureProvider<List<ForestSpecies>>((ref) async {

  // TODO
  // 로그인 사용자 ID 가져오기
  const userId = "TEMP_USER";

  final repo = ForestSpeciesRepository();

  return repo.getSpecies(userId);
});

class ForestBookScreen extends ConsumerWidget {
  const ForestBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final species =
        ref.watch(forestSpeciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forest 도감"),
      ),

      body: species.when(

        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, s) => Center(
          child: Text(e.toString()),
        ),

        data: (items) {

          return GridView.builder(

            padding: const EdgeInsets.all(20),

            itemCount: items.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(

              crossAxisCount: 2,

              crossAxisSpacing: 16,

              mainAxisSpacing: 16,

              childAspectRatio: 0.82,

            ),

            itemBuilder: (_, index) {

              return ForestSpeciesCard(
                species: items[index],
              );

            },
          );
        },
      ),
    );
  }
}
