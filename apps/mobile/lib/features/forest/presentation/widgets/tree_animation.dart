import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TreeAnimation extends StatelessWidget {
  const TreeAnimation({
    super.key,
    required this.level,
  });

  final int level;

  String get asset {

    if (level >= 20) {
      return "assets/animations/big_tree.json";
    }

    if (level >= 10) {
      return "assets/animations/tree.json";
    }

    if (level >= 5) {
      return "assets/animations/young_tree.json";
    }

    if (level >= 2) {
      return "assets/animations/sprout.json";
    }

    return "assets/animations/seed.json";
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 180,
      width: 180,
      child: Lottie.asset(
        asset,
        repeat: true,
        animate: true,
        fit: BoxFit.contain,
      ),
    );
  }
}
