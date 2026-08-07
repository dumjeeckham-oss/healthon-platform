/// ===============================================================
/// HealthON Phase 9 — AI Smart Coach Screen (Enhanced)
///
/// 탭 기반: AI 코치 | AI 채팅 | 챌린지 추천 | 설정
/// ===============================================================

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_provider.dart';
import 'ai_models.dart';
import 'ai_health_chatbot.dart';
import 'smart_challenge_matcher.dart';

class AICoachScreen extends ConsumerStatefulWidget {
  const AICoachScreen({super.key});

  @override
  ConsumerState<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends ConsumerState<AICoachScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _chatController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 스마트 코치'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: '🧠 코치', icon: Icon(Icons.psychology, size: 18)),
            Tab(text: '💬 채팅', icon: Icon(Icons.chat_bubble_outline, size: 18)),
            Tab(text: '🎯 챌린지', icon: Icon(Icons.emoji_events_outlined, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CoachTab(),
          _ChatTab(
            controller: _chatController,
            scrollController: _scrollController,
          ),
          _ChallengeTab(),
        ],
      ),
    );
  }
}

// ===============================================================
// Tab 1: AI 코치 (프로필 + 인사이트 + 리포트)
// ===============================================================

class _CoachTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(aiProfileProvider);
    final insightsAsync = ref.watch(aiInsightsProvider);
    final goals = ref.watch(aiGoalsProvider);
    final weeklyAsync = ref.watch(aiWeeklyReportProvider);
    final activityScore = ref.watch(aiActivityScoreProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(aiProfileProvider);
        ref.invalidate(aiInsightsProvider);
        ref.invalidate(aiWeeklyReportProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === 활동 점수 히어로 ===
          _ActivityScoreHero(score: activityScore),
          const SizedBox(height: 16),

          // === 활동 프로필 카드 ===
          profileAsync.when(
            data: (profile) => _ActivityProfileCard(profile: profile),
            loading: () => const Card(
              child: SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('프로필 분석 불가: $e'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // === AI 인사이트 ===
          const Text('🧠 AI 인사이트',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          insightsAsync.when(
            data: (insights) => Column(
              children: insights.map((i) => _InsightCard(insight: i)).toList(),
            ),
            loading: () => const Card(
              child: SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('인사이트 로드 실패'),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // === AI 추천 목표 ===
          if (goals.isNotEmpty) ...[
            const Text('🎯 맞춤 목표 추천',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...goals.map((g) => _GoalCard(goal: g)),
            const SizedBox(height: 20),
          ],

          // === 주간 리포트 ===
          const Text('📋 주간 리포트',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          weeklyAsync.when(
            data: (report) => _WeeklyReportCard(report: report),
            loading: () => const Card(
              child: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('리포트 생성 실패'),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ===============================================================
// 활동 점수 히어로
// ===============================================================

class _ActivityScoreHero extends StatelessWidget {
  final int score;
  const _ActivityScoreHero({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.lightGreen
            : score >= 40
                ? Colors.orange
                : Colors.red;
    final grade = score >= 90
        ? 'S'
        : score >= 80
            ? 'A'
            : score >= 60
                ? 'B'
                : score >= 40
                    ? 'C'
                    : 'D';

    return Card(
      color: const Color(0xFF1E1E2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // 점수 원
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(color: color, width: 3),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$grade',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: color)),
                    Text('$score점',
                        style: TextStyle(fontSize: 11, color: color)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('활동 점수',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    score >= 80
                        ? '최상의 컨디션이에요! 🚀'
                        : score >= 60
                            ? '꾸준히 잘 하고 있어요 💪'
                            : score >= 40
                                ? '조금만 더 노력하면 좋아질 거예요 🌱'
                                : '천천히 시작해볼까요? 함께 걸어요 🚶',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
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

// ===============================================================
// 활동 프로필 카드
// ===============================================================

class _ActivityProfileCard extends StatelessWidget {
  final UserActivityProfile profile;
  const _ActivityProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E2D),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Text(profile.activityLevelEmoji,
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.activityLevelLabel,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                        '평균 ${_formatNum(profile.avgDailySteps)}걸음/일',
                        style:
                            const TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.analytics_outlined,
                    color: Colors.green.shade300, size: 32),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(
                    label: '일관성',
                    value: '${(profile.consistencyScore * 100).round()}%',
                    color: profile.consistencyScore > 0.6
                        ? Colors.green
                        : Colors.orange),
                _MiniStat(
                    label: '연속 기록',
                    value: '${profile.currentStreak}일',
                    color: profile.currentStreak >= 7
                        ? Colors.green
                        : Colors.white),
                _MiniStat(
                    label: '주간 추세',
                    value: profile.weeklyTrend >= 0
                        ? '+${(profile.weeklyTrend * 100).round()}%'
                        : '${(profile.weeklyTrend * 100).round()}%',
                    color: profile.weeklyTrend >= 0
                        ? Colors.green
                        : Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        ],
      );
}

// ===============================================================
// 인사이트 카드
// ===============================================================

class _InsightCard extends StatelessWidget {
  final AIInsight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (insight.type) {
      InsightType.warning => Colors.orange.shade50,
      InsightType.celebration => Colors.green.shade50,
      InsightType.recommendation => Colors.blue.shade50,
      InsightType.prediction => Colors.purple.shade50,
      InsightType.pattern => Colors.grey.shade100,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(insight.typeEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(insight.description,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700)),
                  if (insight.actionText != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0)),
                      child: Text(insight.actionText!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 목표 추천 카드
// ===============================================================

class _GoalCard extends StatelessWidget {
  final AIGoalRecommendation goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final diffColor = switch (goal.difficulty) {
      'easy' => Colors.green,
      'challenging' => Colors.red,
      _ => Colors.orange
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                    color: diffColor,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(goal.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: diffColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          switch (goal.difficulty) {
                            'easy' => '쉬움',
                            'moderate' => '보통',
                            _ => '도전'
                          },
                          style: TextStyle(
                              fontSize: 11,
                              color: diffColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(goal.description,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(
                    '🎯 ${_formatNum(goal.targetSteps)}걸음  •  ${goal.reason}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
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

// ===============================================================
// 주간 리포트 카드
// ===============================================================

class _WeeklyReportCard extends StatelessWidget {
  final AIWeeklyReport report;
  const _WeeklyReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('이번 주 활동',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: report.vsLastWeek >= 0
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '${report.vsLastWeek >= 0 ? '▲' : '▼'} ${(report.vsLastWeek * 100).abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 11,
                        color: report.vsLastWeek >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ReportStat(
                    label: '총 걸음',
                    value: _formatNum(report.totalSteps)),
                _ReportStat(
                    label: '총 거리',
                    value: '${report.totalDistanceKm.toStringAsFixed(1)}km'),
                _ReportStat(
                    label: '하루 평균',
                    value: _formatNum(report.avgDailySteps)),
              ],
            ),
            const SizedBox(height: 12),
            if (report.bestDaySteps > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '베스트: ${report.bestDayName}요일 ${_formatNum(report.bestDaySteps)}걸음 🏆',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            if (report.personalizedTip != null) ...[
              const Divider(height: 24),
              Text('💬 ${report.personalizedTip!}',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  final String label, value;
  const _ReportStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
}

// ===============================================================
// Tab 2: AI 채팅
// ===============================================================

class _ChatTab extends ConsumerWidget {
  final TextEditingController controller;
  final ScrollController scrollController;

  const _ChatTab({
    required this.controller,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(aiChatMessagesProvider);
    final isLoading = ref.watch(aiChatLoadingProvider);
    final profile = ref.watch(aiProfileProvider).valueOrNull;

    return Column(
      children: [
        // 메시지 리스트
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return _ChatBubble(message: msg);
            },
          ),
        ),

        // 로딩 인디케이터
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircularProgressIndicator(strokeWidth: 2),
                SizedBox(width: 12),
                Text('AI 코치가 답변을 작성 중...',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),

        // 입력창
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2)),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'AI 코치에게 물어보세요...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QuickChip(
                              label: '오늘',
                              onTap: () => controller.text = '오늘 얼마나 걸었어?'),
                          _QuickChip(
                              label: '목표',
                              onTap: () => controller.text = '목표 추천해줘'),
                          _QuickChip(
                              label: '팁',
                              onTap: () => controller.text = '건강 팁 알려줘'),
                        ],
                      ),
                    ),
                    onSubmitted: (text) =>
                        _sendMessage(ref, text, profile),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF2E7D32),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (controller.text.trim().isNotEmpty) {
                              _sendMessage(ref, controller.text.trim(), profile);
                              controller.clear();
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _sendMessage(
      WidgetRef ref, String text, UserActivityProfile? profile) {
    if (text.trim().isEmpty) return;

    final chatbot = ref.read(aiChatbotProvider);

    // 유저 메시지 추가
    ref.read(aiChatMessagesProvider.notifier).update((state) => [
          ...state,
          ChatMessage(text: text, isUser: true),
        ]);

    // 로딩 시작
    ref.read(aiChatLoadingProvider.notifier).state = true;

    // AI 응답 (약간의 지연)
    Future.delayed(const Duration(milliseconds: 800), () {
      final response = chatbot.respond(
        text,
        profile: profile,
        todaySteps: 6500,
        goalSteps: 10000,
        streak: profile?.currentStreak ?? 0,
        forestLevel: 3,
        challengeProgress: 0.65,
        weeklyAvgSteps: profile?.avgWeeklySteps ?? 5000,
      );

      ref.read(aiChatMessagesProvider.notifier).update((state) => [
            ...state,
            ChatMessage(text: response, isUser: false),
          ]);

      ref.read(aiChatLoadingProvider.notifier).state = false;
    });

    // 스크롤 아래로
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF2E7D32)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: message.isUser
                ? const Radius.circular(18)
                : const Radius.circular(4),
            bottomRight: message.isUser
                ? const Radius.circular(4)
                : const Radius.circular(18),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// Tab 3: AI 챌린지 추천
// ===============================================================

class _ChallengeTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(aiChallengeMatchesProvider);
    final profile = ref.watch(aiProfileProvider).valueOrNull;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 헤더
        if (profile != null)
          Card(
            color: const Color(0xFF1E1E2D),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(profile.activityLevelEmoji,
                      style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('맞춤 챌린지 추천',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.activityLevelLabel} 레벨에 딱 맞는 챌린지를 추천해드려요',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // 챌린지 리스트
        if (matches.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('추천 가능한 챌린지가 없어요',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('더 많은 걸음 데이터가 쌓이면\n맞춤 챌린지를 추천해드릴게요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          )
        else
          ...matches.map((m) => _ChallengeMatchCard(match: m)),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _ChallengeMatchCard extends StatelessWidget {
  final ChallengeMatch match;
  const _ChallengeMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final diffColor = switch (match.difficulty) {
      'easy' => Colors.green,
      'moderate' => Colors.orange,
      'challenging' => Colors.red,
      _ => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Expanded(
                  child: Text(match.title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: diffColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: diffColor.withOpacity(0.3)),
                  ),
                  child: Text(match.difficultyLabel,
                      style: TextStyle(
                          fontSize: 12,
                          color: diffColor,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 설명
            Text(match.description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 12),

            // 스탯
            Row(
              children: [
                _ChallengeStat(
                    icon: Icons.directions_walk,
                    label: '${_formatNumInt(match.target)}걸음'),
                const SizedBox(width: 16),
                _ChallengeStat(
                    icon: Icons.calendar_today,
                    label: '${match.durationDays}일'),
                const SizedBox(width: 16),
                _ChallengeStat(
                    icon: Icons.trending_up,
                    label: match.probabilityLabel),
              ],
            ),
            const SizedBox(height: 10),

            // 완주 확률 바
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: match.completionProbability,
                backgroundColor: Colors.grey.shade200,
                color: match.completionProbability >= 0.7
                    ? Colors.green
                    : match.completionProbability >= 0.5
                        ? Colors.orange
                        : Colors.red,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '완주 확률 ${(match.completionProbability * 100).round()}%  •  ${match.recommendedDays}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // 보상 + 시작 버튼
            Row(
              children: [
                Icon(Icons.card_giftcard, size: 16, color: Colors.amber.shade700),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(match.reward,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: const Text('도전하기', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ChallengeStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// ===============================================================
// 유틸리티
// ===============================================================

String _formatNum(int n) {
  return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

String _formatNumInt(int n) {
  if (n >= 10000) {
    return '${(n / 10000).toStringAsFixed(1)}만';
  }
  return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
