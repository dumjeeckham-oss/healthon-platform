class AiCoachService {
  const AiCoachService();

  Future<String> getDailyMessage(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _messages[DateTime.now().day % _messages.length];
  }

  static const List<String> _messages = [
    "좋은 하루입니다 😊 오늘도 건강하게 걸어볼까요?",
    "조금만 더 걸으면 목표에 가까워집니다 👣",
    "꾸준함이 최고의 운동입니다 💪",
    "오늘도 건강ON과 함께 시작해보세요 🌿",
    "100K 챌린지 성공까지 한 걸음 남았습니다 🚶",
    "가족과 함께 걸으면 더 즐겁습니다 ❤️",
    "오늘의 목표를 달성해보세요 🎯",
  ];
}
