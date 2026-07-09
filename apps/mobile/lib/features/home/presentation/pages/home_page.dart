import 'package:flutter/material.dart';

import '../widgets/challenge_card.dart';
import '../widgets/greeting_card.dart';
import '../widgets/today_steps_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("건강ON"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            GreetingCard(
              name: "홍길동",
            ),
            SizedBox(height: 16),
            ChallengeCard(),
            SizedBox(height: 16),
            TodayStepsCard(),
          ],
        ),
      ),
    );
  }
}
