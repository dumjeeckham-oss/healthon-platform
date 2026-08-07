import 'package:flutter/material.dart';

import '../../../../core/services/sound_service.dart';

class LevelUpDialog extends StatelessWidget {
  final int oldLevel;
  final int newLevel;
  final String treeName;

  const LevelUpDialog({
    super.key,
    required this.oldLevel,
    required this.newLevel,
    required this.treeName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('레벨 업!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('$oldLevel → $newLevel'),
            const SizedBox(height: 4),
            Text('$treeName 성장'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
