import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TreeAnimation extends StatelessWidget {
  final int level;

  const TreeAnimation({
    super.key,
    required this.level,
  });

  String get asset {
    if (level >= 20) {
      return "assets/animations/big_tree.svg";
    }

    if (level >= 10) {
      return "assets/animations/tree.svg";
    }

    if (level >= 5) {
      return "assets/animations/young_tree.svg";
    }

    if (level >= 2) {
      return "assets/animations/sprout.svg";
    }

    return "assets/animations/seed.svg";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
      ),
    );
  }
}
