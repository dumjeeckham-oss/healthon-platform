import 'package:flutter/material.dart';

class ChallengeProgressCard extends StatelessWidget {
  final String challengeName;
  final double currentKm;
  final double goalKm;
  final DateTime endDate;

  const ChallengeProgressCard({
    super.key,
    required this.challengeName,
    required this.currentKm,
    required this.goalKm,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentKm / goalKm).clamp(0.0, 1.0);
    final remainKm = (goalKm - currentKm).clamp(0, goalKm);
    final remainDays = endDate.difference(DateTime.now()).inDays;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Row(
              children: [

                const Icon(
                  Icons.emoji_events,
                  color: Colors.orange,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    challengeName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Stack(
              alignment: Alignment.center,
              children: [

                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                  ),
                ),

                Column(
                  children: [

                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${currentKm.toStringAsFixed(1)} km",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                _InfoItem(
                  title: "목표",
                  value: "${goalKm.toInt()}km",
                  icon: Icons.flag,
                ),

                _InfoItem(
                  title: "남은 거리",
                  value: "${remainKm.toStringAsFixed(1)}km",
                  icon: Icons.directions_walk,
                ),

                _InfoItem(
                  title: "남은 기간",
                  value: "$remainDays일",
                  icon: Icons.calendar_today,
                ),
              ],
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
            ),

          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Icon(
          icon,
          color: Colors.green,
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

      ],
    );
  }
}
