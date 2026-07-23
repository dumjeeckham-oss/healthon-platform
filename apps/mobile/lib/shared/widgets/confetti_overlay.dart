import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.play,
  });

  final Widget child;
  final bool play;

  @override
  State<ConfettiOverlay> createState() =>
      _ConfettiOverlayState();
}

class _ConfettiOverlayState
    extends State<ConfettiOverlay> {
  late final ConfettiController controller;

  @override
  void initState() {
    super.initState();

    controller = ConfettiController(
      duration: const Duration(
        seconds: 3,
      ),
    );
  }

  @override
  void didUpdateWidget(
      covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.play && !oldWidget.play) {
      controller.play();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        widget.child,

        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirectionality:
                BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 40,
            gravity: 0.25,
          ),
        ),
      ],
    );
  }
}
