import 'package:flutter/material.dart';

import 'challenge_card.dart';

class ChallengeProgressSection extends StatelessWidget {
  const ChallengeProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        const Text(
          "🏆 진행중인 챌린지",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        const ChallengeCard(
          title: "50K 챌린지",
          goalKm: 50,
          currentKm: 50,
          color: Colors.green,
        ),

        const ChallengeCard(
          title: "100K 챌린지",
          goalKm: 100,
          currentKm: 74,
          color: Colors.orange,
        ),

        const ChallengeCard(
          title: "200K 챌린지",
          goalKm: 200,
          currentKm: 32,
          color: Colors.blue,
        ),
      ],
    );
  }
}
