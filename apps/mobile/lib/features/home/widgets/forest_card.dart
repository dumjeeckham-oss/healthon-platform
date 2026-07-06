import 'package:flutter/material.dart';

import '../../../shared/widgets/info_card.dart';

class ForestCard extends StatelessWidget {
  final int treeCount;
  final int totalKm;

  const ForestCard({
    super.key,
    required this.treeCount,
    required this.totalKm,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "🌳 건강숲",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              Column(
                children: [
                  const Text("누적 거리"),
                  Text(
                    "${totalKm}km",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  const Text("나무"),
                  Text(
                    "$treeCount그루",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            "걸을수록 건강한 숲이 자랍니다 🌱",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
