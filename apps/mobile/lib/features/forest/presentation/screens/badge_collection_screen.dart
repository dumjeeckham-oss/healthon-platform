import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/forest_badge_provider.dart';
import '../widgets/badge_card.dart';
import '../../domain/models/forest_badge.dart';

class BadgeCollectionScreen extends ConsumerWidget {
  const BadgeCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final userId =
        ""; // currentUser.id 연결

    final badges =
        ref.watch(forestBadgeProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forest Badge"),
      ),
      body: badges.when(

        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, s) =>
            Center(child: Text(e.toString())),

        data: (codes) {

          final items = codes
              .map((e) => ForestBadge.fromCode(e, true))
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: items.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),

            itemBuilder: (_, i) {
              return BadgeCard(
                badge: items[i],
              );
            },
          );
        },
      ),
    );
  }
}
