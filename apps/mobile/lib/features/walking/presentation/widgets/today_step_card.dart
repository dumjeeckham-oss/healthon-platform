import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/today_step_provider.dart';

class TodayStepCard extends ConsumerWidget {
  const TodayStepCard({super.key});

  static const int goalSteps = 10000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepAsync = ref.watch(todayStepProvider);

    return stepAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),

      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "걸음수를 불러오지 못했습니다.\n$e",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),

      data: (steps) {
        final progress =
            (steps / goalSteps).clamp(0.0, 1.0);

        final remain =
            (goalSteps - steps).clamp(0, goalSteps);

        final distance =
            (steps * 0.0007);

        final calories =
            (steps * 0.04).round();

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                //----------------------------------
                // 제목
                //----------------------------------

                Row(
                  children: const [

                    Icon(
                      Icons.directions_walk,
                      color: Colors.green,
                    ),

                    SizedBox(width: 8),

                    Text(
                      "오늘의 걸음",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                //----------------------------------
                // 원형 진행률
                //----------------------------------

                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      SizedBox(
                        width: 160,
                        height: 160,
                        child:
                            CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor:
                              Colors.grey.shade300,
                        ),
                      ),

                      Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [

                          Text(
                            "${(progress * 100).toInt()}%",
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "$steps 걸음",
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                //----------------------------------
                // 정보
                //----------------------------------

                Row(
                  children: [

                    Expanded(
                      child: _InfoBox(
                        title: "거리",
                        value:
                            "${distance.toStringAsFixed(2)} km",
                        icon: Icons.route,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _InfoBox(
                        title: "칼로리",
                        value: "$calories kcal",
                        icon: Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                //----------------------------------
                // 남은 걸음
                //----------------------------------

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.green.withOpacity(.08),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [

                      const Icon(
                        Icons.flag,
                        color: Colors.green,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          remain == 0
                              ? "🎉 오늘 목표를 달성했습니다!"
                              : "목표까지 $remain 걸음 남았습니다.",
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        children: [

          Icon(
            icon,
            color: Colors.green,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
