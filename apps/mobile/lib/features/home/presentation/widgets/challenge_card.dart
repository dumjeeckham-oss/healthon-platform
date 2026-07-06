import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {

  const ChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              "🌳 부천 둘레길 100K",

              style: Theme.of(context).textTheme.titleLarge,

            ),

            const SizedBox(height: 20),

            const LinearProgressIndicator(

              value: 0.38,

            ),

            const SizedBox(height: 12),

            const Text(

              "38km / 100km",

            ),

          ],

        ),

      ),

    );

  }

}
