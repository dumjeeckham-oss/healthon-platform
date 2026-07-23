import 'package:flutter/material.dart';

class LevelUpDialog extends StatelessWidget {
  final int oldLevel;
  final int newLevel;
  final String treeName;

  const LevelUpDialog({
    super.key,
    required this.oldLevel,
    required this.newLevel,
    required this.treeName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "🎉 LEVEL UP!",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (_, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: const Text(
                "🌳",
                style: TextStyle(fontSize: 90),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Lv.$oldLevel → Lv.$newLevel",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              treeName,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.park),
              label: const Text("계속 성장하기"),
            )
          ],
        ),
      ),
    );
  }
}
