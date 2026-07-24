import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/daily_mission.dart';
import '../providers/daily_mission_provider.dart';
import '../../application/reward_flow.dart';
import '../../../forest/presentation/widgets/levelup_dialog.dart';
import '../../../forest/presentation/widgets/badge_dialog.dart';

class DailyMissionCard extends ConsumerWidget {
  final List<DailyMission> missions;

  const DailyMissionCard({
    super.key,
    required this.missions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            //------------------------------------------------------
            // Header
            //------------------------------------------------------

            Row(
              children: const [
                Icon(
                  Icons.wb_sunny,
                  color: Colors.orange,
                ),
                SizedBox(width: 10),
                Text(
                  "오늘의 미션",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            //------------------------------------------------------
            // Mission List
            //------------------------------------------------------

            ...missions.map(
              (mission) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _MissionTile(
                  mission: mission,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionTile extends ConsumerWidget {
  final DailyMission mission;

  const _MissionTile({
    required this.mission,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //----------------------------------------------------
          // Title
          //----------------------------------------------------

          Row(
            children: [

              Text(
                mission.icon,
                style: const TextStyle(fontSize: 26),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      mission.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      mission.description,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              if (mission.completed)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),

          const SizedBox(height: 16),

          //----------------------------------------------------
          // Progress
          //----------------------------------------------------

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: mission.percent,
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [

              Text(
                "${mission.progress} / ${mission.goal}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "${mission.rewardValue} ${mission.rewardType}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          //----------------------------------------------------
          // Claim Button
          //----------------------------------------------------

          if (mission.canClaim)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.card_giftcard),
                label: const Text("보상 받기"),
onPressed: () async {

  final rewardFlow = RewardFlow();

  final result = await rewardFlow.execute(

    userId: userId,

    mission: mission,

    totalKm: totalKm,

  );

  if(!context.mounted) return;

  //--------------------------------------------------
  // LevelUp
  //--------------------------------------------------

  if(result.levelUp){

    await showDialog(

      context: context,

      barrierDismissible: false,

      builder: (_) => LevelUpDialog(

        oldLevel: result.oldLevel,

        newLevel: result.newLevel,

        treeName: result.treeName ?? "새로운 나무",

      ),

    );

  }

  //--------------------------------------------------
  // Badge
  //--------------------------------------------------

  if(result.badgeUnlocked){

    await showDialog(

      context: context,

      builder: (_) => BadgeDialog(

        badgeCode: result.badgeCode!,

      ),

    );

  }

},
              ),
            )
          else if (mission.claimed)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "보상 수령 완료",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
