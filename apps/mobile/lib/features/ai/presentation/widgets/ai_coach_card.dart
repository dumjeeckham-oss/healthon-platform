import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_coach_provider.dart';

class AiCoachCard extends ConsumerWidget {
  const AiCoachCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiAsync = ref.watch(aiCoachProvider);

    return aiAsync.when(
      loading: () => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("AI 코치가 분석 중입니다..."),
            ],
          ),
        ),
      ),

      error: (e, _) => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            e.toString(),
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      ),

      data: (ai) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  ai.emoji,
                  style: const TextStyle(fontSize: 42),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        ai.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        ai.message,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.45,
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
