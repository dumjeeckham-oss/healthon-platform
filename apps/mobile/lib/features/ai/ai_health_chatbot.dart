/// ===============================================================
/// HealthON Phase 9 — AI Health Chatbot
///
/// 걸음 데이터 기반 건강 상담 챗봇
/// - 걸음 패턴 분석 Q&A
/// - Forest 성장 조언
/// - 챌린지 전략 상담
/// - 건강 팁 제공
/// ===============================================================

library;

import 'dart:math';

import 'ai_models.dart';

class AIHealthChatbot {
  // =============================================================
  // 챗봇 응답 생성
  // =============================================================

  String respond(String query, {
    required UserActivityProfile? profile,
    required int todaySteps,
    required int goalSteps,
    required int streak,
    required int forestLevel,
    required double challengeProgress,
    required int weeklyAvgSteps,
  }) {
    final lower = query.toLowerCase().trim();

    // 오늘 걸음 질문
    if (_matchAny(lower, ['오늘', '걸음', '얼마', '기록', '지금'])) {
      return _todayStepsResponse(todaySteps, goalSteps);
    }

    // 목표 질문
    if (_matchAny(lower, ['목표', '추천', '몇걸음', '적절', '얼마나'])) {
      return _goalResponse(profile, goalSteps);
    }

    // Forest 질문
    if (_matchAny(lower, ['숲', '나무', 'forest', '성장', '레벨', 'level'])) {
      return _forestResponse(forestLevel, todaySteps);
    }

    // 챌린지 질문
    if (_matchAny(lower, ['챌린지', '대회', '완주', '100k', '도전'])) {
      return _challengeResponse(challengeProgress, weeklyAvgSteps);
    }

    // 연속 기록 질문
    if (_matchAny(lower, ['연속', '스트릭', '기록', '유지', 'streak'])) {
      return _streakResponse(streak, todaySteps);
    }

    // 건강 팁 질문
    if (_matchAny(lower, ['건강', '팁', '조언', '방법', 'tip', '추천'])) {
      return _healthTipResponse(profile);
    }

    // 동기부여 / 힘들 때
    if (_matchAny(lower, ['힘들', '지루', '귀찮', '의욕', '동기', '포기', '그만'])) {
      return _motivationResponse(streak, profile);
    }

    // 패턴 분석
    if (_matchAny(lower, ['패턴', '분석', '통계', '평균', '경향'])) {
      return _patternResponse(profile);
    }

    // 기본 응답
    return _defaultResponse(todaySteps, goalSteps, profile);
  }

  // =============================================================
  // 응답 템플릿
  // =============================================================

  String _todayStepsResponse(int steps, int goal) {
    final percent = goal > 0 ? (steps / goal * 100).round() : 0;
    final formatted = steps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},");

    if (percent >= 100) {
      return '🎉 오늘 이미 $formatted걸음을 걸으셨어요! 목표의 $percent%를 달성했어요. 정말 대단해요!\n\n조금만 더 걸으면 Forest 나무도 더 빨리 자랄 거예요 🌳';
    } else if (percent >= 50) {
      final remaining = goal - steps;
      return '🚶 현재 $formatted걸음으로 목표의 $percent%예요. 앞으로 ${remaining.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음만 더! 저녁 산책 15분이면 충분해요 😊';
    } else if (steps > 0) {
      return '아직 시작이에요! $formatted걸음을 걸으셨어요 (목표의 $percent%). 점심 식사 후 10분 산책이 큰 도움이 될 거예요 🌿';
    } else {
      return '아직 오늘 걸음 기록이 없어요. 하루 7,000걸음이 건강에 좋다고 해요. 지금 잠깐 나가서 가벼운 산책 어떠세요? ☀️';
    }
  }

  String _goalResponse(UserActivityProfile? profile, int currentGoal) {
    if (profile == null) {
      return '아직 충분한 데이터가 쌓이지 않았어요. 일단 하루 7,000걸음을 목표로 시작해보는 건 어떨까요?\n\nWHO는 주 150분 중강도 활동을 권장하고 있어요. 하루 30분 걷기면 충분해요 👣';
    }

    if (profile.activityLevel == 'sedentary') {
      return '현재 활동량은 다소 정적인 편이에요 🪑\n\n처음부터 무리하지 말고 하루 3,000→5,000→7,000걸음 순서로 천천히 늘려가는 걸 추천드려요. 중요한 건 꾸준함이에요!';
    } else if (profile.activityLevel == 'light') {
      return '현재 하루 평균 ${profile.avgDailySteps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음을 걷고 계세요 🚶\n\n다음 목표로 7,000걸음을 추천드려요. 지금 페이스에서 살짝만 더 걸으면 충분히 도달할 수 있어요!';
    } else if (profile.activityLevel == 'moderate') {
      return '꾸준히 잘 걷고 있어요! 평균 ${profile.avgDailySteps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음이에요 🏃\n\n10,000걸음에 도전해보는 건 어떨까요? 지금 페이스면 충분히 가능해요. 챌린지도 함께하면 더 재밌어요!';
    } else {
      return '와, 정말 활발하세요! 평균 ${profile.avgDailySteps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음 💪🔥\n\n${profile.activityLevel == 'very_active' ? "이 정도면 프로 워커예요! 100K 챌린지 완주도 문제없어요. Forest 레벨업을 목표로 달려볼까요?" : "지금 페이스면 모든 챌린지를 정복할 수 있어요. Forest 성장에 집중해보세요!"}';
    }
  }

  String _forestResponse(int level, int todaySteps) {
    final stepsPerDay = todaySteps > 0 ? todaySteps : 5000;
    final rawNeeded = (50000 * pow(1.15, level) * 0.7).round();
    final days = (rawNeeded / stepsPerDay).ceil();

    return '🌳 현재 Forest 레벨 $level이에요!\n\n'
        '지금 페이스(하루 ${stepsPerDay.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음)면 약 $days일 후에 다음 레벨에 도달할 거예요.\n\n'
        '더 빨리 성장하려면 하루 2,000걸음만 더 걸어보세요. 작은 차이가 큰 변화를 만들어요 🌱';
  }

  String _challengeResponse(double progress, int weeklyAvg) {
    final percent = (progress * 100).round();

    if (progress >= 1.0) {
      return '🏆 이미 완주하셨어요! 축하드려요 🎉\n\n다음 목표는 어떠세요? 더 높은 목표의 챌린지에 도전하거나, Forest 레벨업에 집중해보는 것도 좋아요!';
    } else if (progress >= 0.8) {
      return '🔥 완주까지 ${(100 - percent)}% 남았어요! 거의 다 왔어요.\n\n하루 ${((100000 * (1 - progress)) / 7).round().toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음씩이면 일주일 안에 완주! 조금만 더 힘내세요 💪';
    } else if (progress >= 0.5) {
      return '💪 절반을 넘으셨어요! 현재 $percent% 달성.\n\n주간 평균 ${weeklyAvg.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음이면 충분히 완주 가능해요. 꾸준함이 답이에요!';
    } else {
      final needed = (100000 * (1 - progress)).round();
      return '🚩 챌린지 $percent% 진행 중! 앞으로 ${needed.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음을 더 걸어야 해요.\n\n하루 7,000걸음이면 약 ${(needed / 7000).ceil()}일 후 완주할 수 있어요. 천천히, 꾸준히!';
    }
  }

  String _streakResponse(int streak, int todaySteps) {
    if (streak >= 30) {
      return '🏅 $streak일 연속 기록! 한 달 동안 매일 걸으셨어요.\n\n이 정도면 걷기가 완전한 습관이 된 거예요. 정말 자랑스러워요! 앞으로도 계속 건강한 습관 이어가요 🌟';
    } else if (streak >= 14) {
      return '🔥 $streak일 연속 기록! 2주 동안 매일 걷고 있어요.\n\n곧 21일이 되면 습관이 완전히 자리잡는다고 해요. 조금만 더!';
    } else if (streak >= 7) {
      return '⭐ $streak일 연속! 일주일 내내 걸으셨어요.\n\n연구에 따르면 21일이면 새로운 습관이 형성된다고 해요. 앞으로 14일만 더 도전해볼까요?';
    } else if (streak >= 3) {
      return '👏 $streak일 연속 기록 중! 좋은 시작이에요.\n\n오늘도 기록을 이어가면 ${streak + 1}일이 돼요. 지금 ${todaySteps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음, 조금만 더 걸어볼까요?';
    } else {
      return '아직 연속 기록을 쌓는 중이에요. 3일 연속만 달성해도 동기부여가 확 올라갈 거예요! 오늘부터 시작해볼까요? 🚀';
    }
  }

  String _healthTipResponse(UserActivityProfile? profile) {
    final tips = [
      '💡 하루 30분 걷기만으로도 심장병 위험을 19% 낮출 수 있다는 연구 결과가 있어요.',
      '🌿 점심 식사 후 10분 산책이 혈당 조절에 큰 도움이 돼요.',
      '📱 스마트폰을 보며 걷지 말고, 주변 풍경을 감상하며 걸어보세요. 정신 건강에도 좋아요!',
      '🎵 좋아하는 음악이나 팟캐스트를 들으며 걸으면 시간이 훨씬 빨리 가요.',
      '👫 친구나 가족과 함께 걸으면 지속률이 2배 이상 높아진대요. 커뮤니티에 초대해보세요!',
      '⏰ 매일 같은 시간에 걷는 습관을 들이면 몸이 자연스럽게 리듬을 타게 돼요.',
      '🦵 계단 이용하기, 한 정거장 먼저 내려서 걷기 등 작은 습관부터 시작해보세요.',
    ];

    final random = tips[DateTime.now().day % tips.length];

    String personalized = '';
    if (profile != null) {
      if (profile.consistencyScore < 0.4) {
        personalized = '\n\n현재 걸음 패턴이 다소 불규칙해요. 매일 같은 시간에 걷는 습관을 추천드려요!';
      } else if (profile.currentStreak >= 7) {
        personalized = '\n\n${profile.currentStreak}일 연속 걷기 중! 지금처럼 꾸준히 하면 건강이 확실히 좋아질 거예요 💪';
      }
    }

    return '$random$personalized';
  }

  String _motivationResponse(int streak, UserActivityProfile? profile) {
    if (streak >= 14) {
      return '$streak일이나 걸어오셨는데, 오늘 포기하기엔 너무 아까워요! 😢\n\n잠깐 쉬는 것도 좋지만, 5분만이라도 걸어보세요. "오늘은 쉬는 날"보다 "오늘도 걸었다"가 훨씬 기분 좋답니다!\n\nForest 나무도 당신을 기다리고 있어요 🌳';
    } else if (streak >= 5) {
      return '$streak일 연속! 벌써 습관이 자리잡기 시작했어요.\n\n모든 위대한 변화는 작은 습관에서 시작돼요. 오늘 딱 10분만 걸어볼까요? 10분이 지나면 어느새 더 걷고 있는 자신을 발견할 거예요 🚶';
    } else {
      return '누구에게나 의욕이 떨어지는 날은 있어요. 그럴 땐 목표를 낮춰보세요.\n\n"오늘은 딱 1,000걸음만" 이라고 생각하고 시작해보세요. 시작이 가장 어려운 법! 첫걸음을 떼면 나머지는 자연스럽게 따라와요 🌱';
    }
  }

  String _patternResponse(UserActivityProfile? profile) {
    if (profile == null) {
      return '아직 충분한 데이터가 쌓이지 않았어요. 일주일 정도 꾸준히 걸으면 패턴 분석이 가능해져요. 조금만 기다려주세요! ⏳';
    }

    final trend = profile.weeklyTrend >= 0 ? '증가' : '감소';
    final trendPercent = (profile.weeklyTrend.abs() * 100).round();

    return '📊 활동 분석 리포트\n\n'
        '• 일평균: ${profile.avgDailySteps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음\n'
        '• 활동 레벨: ${profile.activityLevelLabel} ${profile.activityLevelEmoji}\n'
        '• 일관성: ${(profile.consistencyScore * 100).round()}점\n'
        '• 연속 기록: ${profile.currentStreak}일\n'
        '• 주간 추세: $trendPercent% $trend\n'
        '• 최고 기록: ${profile.maxDailySteps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음\n\n'
        '${profile.consistencyScore > 0.6 ? "일관성 점수가 높아요! 규칙적인 습관이 잘 자리잡았네요 👍" : "조금 더 규칙적으로 걸으면 더 좋은 결과를 얻을 수 있어요. 매일 같은 시간이 효과적이에요!"}';
  }

  String _defaultResponse(int steps, int goal, UserActivityProfile? profile) {
    final name = '건강ON AI 코치';

    if (steps > 0) {
      return '안녕하세요! $name입니다 🖐️\n\n'
          '오늘 ${steps.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}걸음을 걸으셨어요. '
          '${goal > 0 && steps >= goal ? "목표 달성! 🎉" : "목표까지 ${goal > 0 ? (goal - steps).toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},") : "?"}걸음 남았어요."}\n\n'
          '물어보고 싶은 게 있으신가요?\n'
          '• "오늘 얼마나 걸었어?"\n'
          '• "목표 추천해줘"\n'
          '• "Forest 언제 자라?"\n'
          '• "챌린지 얼마나 남았어?"\n'
          '• "건강 팁 알려줘"';
    } else {
      return '안녕하세요! $name입니다 🖐️\n\n'
          '아직 오늘 걸음 기록이 없어요. 앱을 열고 산책을 시작해보세요!\n\n'
          '궁금한 점을 물어보세요:\n'
          '• "하루에 몇 걸음 걸어야 해?"\n'
          '• "어떻게 시작하면 좋을까?"\n'
          '• "Forest는 뭐야?"';
    }
  }

  // =============================================================
  // 유틸리티
  // =============================================================

  bool _matchAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }
}

// ===============================================================
// 챗봇 메시지 모델
// ===============================================================

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType type;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.type = ChatMessageType.text,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum ChatMessageType { text, insight, recommendation, report }
