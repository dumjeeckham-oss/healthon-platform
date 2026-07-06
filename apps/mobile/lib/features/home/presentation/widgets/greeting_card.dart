import 'package:flutter/material.dart';

class GreetingCard extends StatelessWidget {
  final String name;

  const GreetingCard({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      elevation: 1,

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              "$name님 👋",

              style: Theme.of(context).textTheme.headlineSmall,

            ),

            const SizedBox(height: 10),

            Text(

              "오늘도 건강한 하루를 시작해볼까요?",

              style: Theme.of(context).textTheme.bodyLarge,

            ),

          ],

        ),

      ),

    );

  }

}
