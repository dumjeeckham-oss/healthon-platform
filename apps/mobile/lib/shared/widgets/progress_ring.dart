import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 ~ 1.0
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final Widget? center;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.progressColor = const Color(0xff2E7D32),
    this.backgroundColor = const Color(0xffE8F5E9),
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // 배경 원
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation(backgroundColor),
            ),
          ),

          // 진행 원
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: safeProgress,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),

          // 중앙 콘텐츠
          if (center != null) center!,
        ],
      ),
    );
  }
}
