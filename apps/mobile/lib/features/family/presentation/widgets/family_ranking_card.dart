import 'package:flutter/material.dart';

class FamilyRankingCard extends StatelessWidget {
  const FamilyRankingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: const [

                Icon(
                  Icons.family_restroom,
                  color: Colors.green,
                ),

                SizedBox(width: 8),

                Text(
                  "가족 랭킹",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const _RankingTile(
              rank: 1,
              name: "아빠",
              steps: 15820,
              highlight: false,
            ),

            const Divider(),

            const _RankingTile(
              rank: 2,
              name: "나",
              steps: 12340,
              highlight: true,
            ),

            const Divider(),

            const _RankingTile(
              rank: 3,
              name: "엄마",
              steps: 11480,
              highlight: false,
            ),

            const Divider(),

            const _RankingTile(
              rank: 4,
              name: "민준",
              steps: 8920,
              highlight: false,
            ),

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.leaderboard),
              label: const Text("전체 랭킹 보기"),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  final int rank;
  final String name;
  final int steps;
  final bool highlight;

  const _RankingTile({
    required this.rank,
    required this.name,
    required this.steps,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.green.withOpacity(.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 16,
            backgroundColor: _rankColor(rank),
            child: Text(
              "$rank",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: highlight
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),

          Text(
            "${steps.toString()} 걸음",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.orange;

      case 2:
        return Colors.blue;

      case 3:
        return Colors.brown;

      default:
        return Colors.grey;
    }
  }
}
