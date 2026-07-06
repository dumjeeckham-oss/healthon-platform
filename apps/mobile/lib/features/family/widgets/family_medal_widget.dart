import 'package:flutter/material.dart';

/// ===============================================================
///
/// Family Medal Widget
///
/// HealthON Release v1
///
/// ===============================================================

class FamilyMedalWidget extends StatelessWidget {
  final int rank;

  final double size;

  const FamilyMedalWidget({
    super.key,
    required this.rank,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    switch (rank) {
      case 0:
        return _emoji(
          "🥇",
          Colors.amber,
        );

      case 1:
        return _emoji(
          "🥈",
          Colors.grey,
        );

      case 2:
        return _emoji(
          "🥉",
          Colors.brown,
        );

      default:
        return CircleAvatar(
          radius: size / 2,
          backgroundColor:
              Colors.blue.shade50,
          child: Text(
            "${rank + 1}",
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: size * 0.36,
            ),
          ),
        );
    }
  }

  Widget _emoji(
    String emoji,
    Color color,
  ) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        emoji,
        style: TextStyle(
          fontSize: size * .65,
        ),
      ),
    );
  }
}
