import 'dart:math' as math;

import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 ~ 1.0
  final double currentDistance;
  final double goalDistance;
  final double todayDistance;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.currentDistance,
    required this.goalDistance,
    required this.todayDistance,
  });

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);

    Color color;

    if (value < 0.3) {
      color = Colors.blue;
    } else if (value < 0.7) {
      color = Colors.green;
    } else if (value < 1.0) {
      color = Colors.orange;
    } else {
      color = Colors.amber;
    }

    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 1200),
            builder: (context, animationValue, _) {
              return CustomPaint(
                painter: _RingPainter(
                  progress: animationValue,
                  color: color,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 34,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${(animationValue * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "${currentDistance.toStringAsFixed(1)} km / ${goalDistance.toStringAsFixed(0)} km",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Text(
          "🎯 ${(goalDistance - currentDistance).clamp(0, goalDistance).toStringAsFixed(1)} km 남았습니다",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          "👣 오늘 +${todayDistance.toStringAsFixed(1)} km",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;

    final center = Offset(size.width / 2, size.height / 2);

    final radius = (size.width - stroke) / 2;

    final background = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final foreground = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, background);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
