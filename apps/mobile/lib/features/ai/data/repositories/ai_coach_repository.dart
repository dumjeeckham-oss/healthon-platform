import '../../../challenge/domain/models/challenge_summary.dart';
import '../../domain/models/ai_coach_message.dart';

class AiCoachRepository {
  Future<AiCoachMessage> buildMessage({
    required int todaySteps,
    required ChallengeSummary challenge,
  }) async {
    final todayKm = todaySteps / 1300.0;

    if (challenge.progress >= 1.0) {
      return const AiCoachMessage(
        emoji: "🏆",
        title: "완주 성공!",
        message: "100K 챌린지를 완주했습니다.\n정말 대단합니다!",
      );
    }

    if (todayKm >= challenge.todayGoal) {
      return const AiCoachMessage(
        emoji: "🎉",
        title: "오늘 목표 달성!",
        message: "오늘 목표를 달성했습니다.\n좋은 흐름을 이어가세요.",
      );
    }

    if (challenge.progress >= 0.8) {
      return const AiCoachMessage(
        emoji: "🔥",
        title: "거의 다 왔어요",
        message: "완주까지 얼마 남지 않았습니다!",
      );
    }

    if (challenge.progress >= 0.5) {
      return const AiCoachMessage(
        emoji: "💪",
        title: "절반 돌파",
        message: "벌써 절반 이상을 걸었습니다.",
      );
    }

    return const AiCoachMessage(
      emoji: "🚶",
      title: "오늘도 한 걸음",
      message: "작은 걸음이 큰 변화를 만듭니다.",
    );
  }
}
