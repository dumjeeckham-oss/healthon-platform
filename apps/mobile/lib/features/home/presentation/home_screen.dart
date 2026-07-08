import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/provider/current_user_provider.dart';
import '../../ai/presentation/widgets/ai_coach_card.dart';
import '../../walking/presentation/widgets/today_step_card.dart';
import '../../challenge/presentation/widgets/challenge_progress_section.dart';
import '../../challenge/presentation/widgets/team_cheer_card.dart';
import '../../family/presentation/widgets/family_ranking_card.dart';
import '../../notice/presentation/widgets/notice_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    final displayName =
    user?.nickname?.isNotEmpty == true
        ? user!.nickname!
        : user?.name?.isNotEmpty == true
            ? user!.name!
            : user?.email ?? "조합원";

    final photoUrl = user?.photoUrl;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("건강ON"),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO
            // Sprint3에서 Health Connect 다시 동기화
            await _syncSteps();
             ref.invalidate(todayStepProvider);

             ref.invalidate(currentUserProvider);
      },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [

              //--------------------------------------------------
              // 인사말
              //--------------------------------------------------

         Row(
  children: [

    CircleAvatar(
      radius: 28,
      backgroundColor: Colors.green.shade100,

      backgroundImage:
          photoUrl != null && photoUrl.isNotEmpty
        ? NetworkImage(photoUrl)
        : null,

      child: user?.photoUrl == null ||
              photoUrl.isEmpty
          ? const Icon(
              Icons.person,
              size: 30,
              color: Colors.green,
            )
          : null,
    ),

    const SizedBox(width: 16),

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "안녕하세요 👋",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            displayName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),

          const Text(
            "오늘도 건강한 하루를 시작해보세요.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  ],
),

              //--------------------------------------------------
              // 오늘 걸음수
              //--------------------------------------------------

              TodayStepCard(),

              SizedBox(height: 20),

              //--------------------------------------------------
              // AI 코치
              //--------------------------------------------------

              AiCoachCard(),

              SizedBox(height: 24),

              ChallengeProgressSection(),

              SizedBox(height: 24),

              TeamCheerCard(),

              SizedBox(height: 24),

              FamilyRankingCard(),

              SizedBox(height: 24),

              NoticeCard(),

              SizedBox(height: 30),

              //--------------------------------------------------
              // 빠른 메뉴
              //--------------------------------------------------

              Text(
                "빠른 메뉴",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              SizedBox(height: 16),

              _QuickMenu(),

              SizedBox(height: 24),

              //--------------------------------------------------
              // 최근 활동
              //--------------------------------------------------

              Text(
                "최근 활동",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              SizedBox(height: 16),

              _RecentActivity(),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickMenu extends StatelessWidget {
  const _QuickMenu();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.45,
      children: [
        _MenuCard(
          icon: Icons.emoji_events,
          title: "100K 챌린지",
          subtitle: "현재 진행률",
        ),
        _MenuCard(
          icon: Icons.family_restroom,
          title: "가족 랭킹",
          subtitle: "이번 주 순위",
        ),
        _MenuCard(
          icon: Icons.bar_chart,
          title: "통계",
          subtitle: "걸음 분석",
        ),
        _MenuCard(
          icon: Icons.campaign,
          title: "공지사항",
          subtitle: "새로운 소식",
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 34,
                color: Colors.green,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.directions_walk),
            title: Text("오늘 7,820걸음 달성"),
            subtitle: Text("10분 전"),
          ),
          Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.emoji_events),
            title: Text("100K 챌린지 참여"),
            subtitle: Text("어제"),
          ),
          Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.favorite),
            title: Text("AI 코치 응원 메시지 도착"),
            subtitle: Text("어제"),
          ),
        ],
      ),
    );
  }
}
