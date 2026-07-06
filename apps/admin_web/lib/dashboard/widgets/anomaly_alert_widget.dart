import 'package:flutter/material.dart';

class AnomalyAlertWidget extends StatelessWidget {
  final List<String> inactiveUsers;

  const AnomalyAlertWidget({
    super.key,
    required this.inactiveUsers,
  });

  @override
  Widget build(BuildContext context) {
    if (inactiveUsers.isEmpty) {
      return const SizedBox();
    }

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚠️ 이상 사용자 감지",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("비활성 사용자: ${inactiveUsers.length}명"),
          ],
        ),
      ),
    );
  }
}