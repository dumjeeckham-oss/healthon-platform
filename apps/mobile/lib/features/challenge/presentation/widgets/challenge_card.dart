import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.title,
    required this.goalKm,
    required this.currentKm,
    required this.color,
  });

  final String title;
  final double goalKm;
  final double currentKm;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress =
        (currentKm / goalKm).clamp(0.0, 1.0);

    final completed = currentKm >= goalKm;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(.15),
                  child: Icon(
                    Icons.directions_walk,
                    color: color,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                if (completed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "완료",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: Colors.grey.shade300,
              color: color,
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  "${currentKm.toStringAsFixed(1)} km",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                Text(
                  "${goalKm.toStringAsFixed(0)} km",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              _message(progress),
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _message(double progress) {
    if (progress >= 1) {
      return "🎉 목표를 달성했습니다!";
    }

    if (progress >= .8) {
      return "거의 다 왔어요!";
    }

    if (progress >= .5) {
      return "절반을 넘었습니다.";
    }

    if (progress >= .2) {
      return "좋은 페이스입니다.";
    }

    return "첫 걸음을 시작했습니다.";
  }
}
