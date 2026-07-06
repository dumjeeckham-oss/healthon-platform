import 'package:flutter/material.dart';

class ActivityRateChart extends StatelessWidget {
  final double rate;

  const ActivityRateChart({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "🔥 활성률\n${(rate * 100).toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}