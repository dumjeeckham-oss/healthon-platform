import 'package:flutter/material.dart';

import '../../../features/daily_mission/domain/models/reward_result.dart';
import '../../../features/forest/domain/models/forest_badge.dart';

import '../../../features/forest/presentation/dialogs/level_up_dialog.dart';
import '../../../features/forest/presentation/widgets/badge_dialog.dart';
import '../../../features/forest/presentation/widgets/tree_unlock_dialog.dart';

import '../../services/sound_service.dart';

class RewardPresentationManager {
  RewardPresentationManager._();

  /// ==========================================================
  /// Reward Queue 실행
  /// ==========================================================
  static Future<void> show(
    BuildContext context,
    RewardResult result,
  ) async {
    if (!context.mounted) return;

    //----------------------------------------------------------
    // Queue가 없으면 종료
    //----------------------------------------------------------

    if (result.queue.isEmpty) return;

    //----------------------------------------------------------
    // Queue 순차 실행
    //----------------------------------------------------------

    for (final event in result.queue) {
      switch (event) {
        //------------------------------------------------------
        // LEVEL UP
        //------------------------------------------------------

        case RewardPresentationType.levelUp:

          await SoundService.instance.playLevelUp();

          if (!context.mounted) return;

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => LevelUpDialog(
              oldLevel: result.oldLevel,
              newLevel: result.newLevel,
              treeName:
                  result.treeName ??
                  "새로운 나무",
            ),
          );

          break;

        //------------------------------------------------------
        // TREE UNLOCK
        //------------------------------------------------------

        case RewardPresentationType.treeUnlock:

          await SoundService.instance.playForestGrow();

          if (!context.mounted) return;

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => TreeUnlockDialog(
              treeName:
                  result.treeName ??
                  "새로운 나무",
            ),
          );

          break;

        //------------------------------------------------------
        // BADGE
        //------------------------------------------------------

        case RewardPresentationType.badge:

          await SoundService.instance.playBadge();

          if (!context.mounted) return;

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => BadgeDialog(
              badge: ForestBadge(
                code: result.badgeCode ?? '',
                title: '',
                description: '',
                icon: '🏅',
                unlocked: true,
              ),
            ),
          );

          break;

        //------------------------------------------------------
        // GARDEN
        //------------------------------------------------------

        case RewardPresentationType.gardenUnlock:

          await SoundService.instance.playForestGrow();

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "🌳 새로운 Garden Tile이 열렸습니다!",
              ),
              duration: Duration(
                seconds: 2,
              ),
            ),
          );

          break;

        //------------------------------------------------------
        // SEASON EVENT
        //------------------------------------------------------

        case RewardPresentationType.seasonReward:

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "🍁 계절 보상을 획득했습니다.",
              ),
            ),
          );

          break;

        //------------------------------------------------------
        // RARE ANIMAL
        //------------------------------------------------------

        case RewardPresentationType.rareAnimal:

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "🦉 희귀 동물이 나타났습니다!",
              ),
            ),
          );

          break;
      }

      //--------------------------------------------------------
      // Dialog 사이 자연스러운 텀
      //--------------------------------------------------------

      await Future.delayed(
        const Duration(
          milliseconds: 250,
        ),
      );
    }
  }
}
