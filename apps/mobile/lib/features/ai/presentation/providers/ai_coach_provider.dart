import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/ai_coach_repository.dart';
import '../../../walking/presentation/providers/today_steps_provider.dart';
import '../../../challenge/presentation/providers/challenge_provider.dart';

final aiCoachProvider =
    FutureProvider.autoDispose((ref) async {

  final todaySteps =
      await ref.watch(todayStepsProvider.future);

  final challenge =
      await ref.watch(challengeProvider.future);

  final repository = AiCoachRepository();

  return repository.buildMessage(
    todaySteps: todaySteps,
    challenge: challenge,
  );
});
