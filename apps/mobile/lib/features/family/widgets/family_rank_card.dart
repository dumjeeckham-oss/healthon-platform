import 'package:flutter/material.dart';

import '../models/family_member_ranking.dart';
import 'family_stat_chip.dart';

/// ===============================================================
///
/// FamilyRankCard
///
/// HealthON Release v1
///
/// ===============================================================

class FamilyRankCard extends StatelessWidget {
  final FamilyMemberRanking member;
  final int rank;
  final VoidCallback? onCheer;

  const FamilyRankCard({
    super.key,
    required this.member,
    required this.rank,
    this.onCheer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: rank == 0 ? 5 : 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                _buildRankBadge(),

                const SizedBox(width: 14),

                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    member.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(width: 6),

                          Text(
                            member.badge,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),

                          if (member.isLeader) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                          ]
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        member.status,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                FilledButton.icon(
                  onPressed: onCheer,
                  icon: const Icon(Icons.favorite),
                  label: Text("${member.cheers}"),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                const Icon(
                  Icons.directions_walk,
                  color: Colors.green,
                ),

                const SizedBox(width: 8),

                Text(
                  member.formattedSteps,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 5),

                const Text("보"),
              ],
            ),

            const SizedBox(height: 14),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: member.progress(),
                minHeight: 12,
              ),
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [

                FamilyStatChip(
                  icon: Icons.local_fire_department,
                  label: "${member.streak}일",
                  color: Colors.orange,
                ),

                FamilyStatChip(
                  icon: member.isGrowing
                      ? Icons.trending_up
                      : Icons.trending_down,
                  label:
                      "${member.growth > 0 ? "+" : ""}${member.growth.toStringAsFixed(0)}%",
                  color: member.isGrowing
                      ? Colors.green
                      : Colors.red,
                ),

                FamilyStatChip(
                  icon: Icons.workspace_premium,
                  label: "Lv.${member.level}",
                  color: Colors.blue,
                ),

                FamilyStatChip(
                  icon: Icons.favorite,
                  label: "응원 ${member.cheers}",
                  color: Colors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    switch (rank) {
      case 0:
        return const Text(
          "🥇",
          style: TextStyle(fontSize: 32),
        );

      case 1:
        return const Text(
          "🥈",
          style: TextStyle(fontSize: 32),
        );

      case 2:
        return const Text(
          "🥉",
          style: TextStyle(fontSize: 32),
        );

      default:
        return CircleAvatar(
          radius: 16,
          child: Text("${rank + 1}"),
        );
    }
  }
}
