import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class TreeAnimation extends StatelessWidget {
  final int level;

  const TreeAnimation({
    super.key,
    required this.level,
  });

  String get animation {
    if (level >= 20) {
      return "tree_big";
    }

    if (level >= 10) {
      return "tree_medium";
    }

    if (level >= 5) {
      return "tree_small";
    }

    if (level >= 2) {
      return "sprout";
    }

    return "seed";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: RiveAnimation.asset(
        "assets/animations/tree.riv",
        animations: [animation],
        fit: BoxFit.contain,
      ),
    );
  }
}
