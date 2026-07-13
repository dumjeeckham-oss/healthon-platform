import '../repositories/challenge_repository.dart';

class ChallengeService {
  ChallengeService(this._repository);

  final ChallengeRepository _repository;

  // 목표 거리(km)
  static const double goalDistance = 100.0;

  /// ----------------------------------------------------------
  /// 오늘 거리 반영
  /// ----------------------------------------------------------
  Future<void> syncTodayDistance({
    required String userId,
    required double todayDistance,
  }) async {
    final current = await _repository.getTotalDistance(userId);

    final total = current + todayDistance;

    await _repository.updateProgress(
      userId: userId,
      totalDistance: total,
    );
  }

  /// ----------------------------------------------------------
  /// 현재 누적거리
  /// ----------------------------------------------------------
  Future<double> getTotalDistance(String userId) {
    return _repository.getTotalDistance(userId);
  }

  /// ----------------------------------------------------------
  /// 진행률(0~1)
  /// ----------------------------------------------------------
  Future<double> getProgress(String userId) {
    return _repository.getProgress(userId);
  }

  /// ----------------------------------------------------------
  /// 퍼센트(0~100)
  /// ----------------------------------------------------------
  Future<double> getProgressPercent(String userId) async {
    final progress = await getProgress(userId);

    return progress * 100;
  }

  /// ----------------------------------------------------------
  /// 남은 거리
  /// ----------------------------------------------------------
  Future<double> getRemainingDistance(String userId) {
    return _repository.getRemainingDistance(userId);
  }

  /// ----------------------------------------------------------
  /// 완주 여부
  /// ----------------------------------------------------------
  Future<bool> isCompleted(String userId) {
    return _repository.isCompleted(userId);
  }

  /// ----------------------------------------------------------
  /// 상태 메시지
  /// ----------------------------------------------------------
  Future<String> getStatusMessage(String userId) async {
    final remain = await getRemainingDistance(userId);

    if (remain <= 0) {
      return "🎉 100km 완주를 축하합니다!";
    }

    if (remain <= 5) {
      return "🔥 거의 다 왔어요! 조금만 더!";
    }

    if (remain <= 20) {
      return "💪 완주가 눈앞입니다.";
    }

    return "${remain.toStringAsFixed(1)}km 남았습니다.";
  }

  /// ----------------------------------------------------------
  /// Forest 성장 단계
  /// ----------------------------------------------------------
  Future<int> getForestLevel(String userId) async {
    final percent = await getProgressPercent(userId);

    if (percent >= 100) return 5;
    if (percent >= 80) return 4;
    if (percent >= 60) return 3;
    if (percent >= 40) return 2;
    if (percent >= 20) return 1;

    return 0;
  }

  /// ----------------------------------------------------------
  /// Forest 이름
  /// ----------------------------------------------------------
  Future<String> getForestName(String userId) async {
    final level = await getForestLevel(userId);

    switch (level) {
      case 0:
        return "새싹";
      case 1:
        return "묘목";
      case 2:
        return "어린나무";
      case 3:
        return "푸른나무";
      case 4:
        return "큰나무";
      case 5:
        return "건강ON 숲";
      default:
        return "새싹";
    }
  }
}
