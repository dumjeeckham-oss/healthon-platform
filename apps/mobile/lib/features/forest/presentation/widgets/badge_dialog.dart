import 'package:flutter/material.dart';

import '../../../../core/services/sound_service.dart';
import '../../domain/models/forest_badge.dart';

class BadgeDialog extends StatefulWidget {
  final ForestBadge badge;

  const BadgeDialog({
    super.key,
    required this.badge,
  });

  @override
  State<BadgeDialog> createState() => _BadgeDialogState();
}

class _BadgeDialogState extends State<BadgeDialog> {

  @override
  void initState() {
    super.initState();

    SoundService.instance.playBadge();
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),

      title: const Center(
        child: Text(
          "🏅 배지 획득!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Text(
            widget.badge.icon,
            style: const TextStyle(
              fontSize: 72,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            widget.badge.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            widget.badge.description,
            textAlign: TextAlign.center,
          ),
        ],
      ),

      actions: [

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(

            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("확인"),
          ),
        ),
      ],
    );
  }
}
