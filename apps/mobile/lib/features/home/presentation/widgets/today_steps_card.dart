import 'package:flutter/material.dart';
import '../../walking/presentation/providers/walking_provider.dart';

class TodayStepsCard extends StatelessWidget {

  const TodayStepsCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Row(

          children: [

            const Icon(
              Icons.directions_walk,
              size: 40,
            ),

            const SizedBox(width: 20),

            Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  "오늘 걸음",

                  style: Theme.of(context).textTheme.titleMedium,

                ),

                const SizedBox(height: 6),

                Text(

                  "8,523",

                  style: Theme.of(context).textTheme.headlineMedium,

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }

}
