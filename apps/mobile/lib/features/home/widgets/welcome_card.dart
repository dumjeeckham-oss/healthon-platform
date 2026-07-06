import 'package:flutter/material.dart';

class WelcomeCard extends StatelessWidget {
  final String userName;
  final String challengeName;

  const WelcomeCard({
    super.key,
    required this.userName,
    required this.challengeName,
  });

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "좋은 아침입니다 ☀️";
    }

    if (hour < 18) {
      return "좋은 오후입니다 🌿";
    }

    return "편안한 저녁입니다 🌙";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              _greeting(),
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "$userName님",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "$challengeName에 참여 중입니다.",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
