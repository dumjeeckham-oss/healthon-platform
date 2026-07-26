import 'package:flutter/material.dart';

class TreeUnlockDialog extends StatelessWidget {
  final String treeName;

  const TreeUnlockDialog({
    super.key,
    required this.treeName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "🌳 새로운 나무 발견!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "🌲",
              style: TextStyle(fontSize: 90),
            ),

            const SizedBox(height: 20),

            Text(
              treeName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Forest 도감에 등록되었습니다.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("확인"),
            )
          ],
        ),
      ),
    );
  }
}
