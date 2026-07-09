import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/provider/current_user_provider.dart';
import '../../ai_coach_service.dart';
import '../../../walking/data/step_repository_impl.dart';

final aiCoachMessageProvider =
    FutureProvider.autoDispose<String>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return '로그인하면 오늘의 맞춤 응원 메시지를 받을 수 있어요.';
  }

  final service = AiCoachService(StepRepositoryImpl());

  return service.getDailyMessage(user.id);
});

class AiCoachCard extends ConsumerWidget {
  const AiCoachCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(aiCoachMessageProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(
                Icons.favorite,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 응원',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  message.when(
                    loading: () => const Text('응원 메시지를 준비하고 있어요.'),
                    error: (_, _) => const Text(
                      '오늘도 천천히, 건강하게 걸어볼까요?',
                    ),
                    data: (text) => Text(
                      text,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
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
  }
}
