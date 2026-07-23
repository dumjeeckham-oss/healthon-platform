import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/current_user_provider.dart';
import '../../ai/presentation/widgets/ai_coach_card.dart';
import '../../walking/presentation/widgets/today_step_card.dart';
import '../../walking/presentation/providers/today_steps_provider.dart';
import '../../challenge/presentation/providers/challenge_provider.dart';
import '../../challenge/presentation/widgets/challenge_progress_section.dart';
import '../../challenge/presentation/widgets/team_cheer_card.dart';
import '../../family/presentation/widgets/family_ranking_card.dart';
import '../../notice/presentation/widgets/notice_card.dart';
import '../../forest/presentation/widgets/forest_card.dart';
import '../../forest/presentation/providers/forest_provider.dart';
import '../../forest/presentation/screens/forest_book_screen.dart';


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
    ref.watch(walkingSyncProvider);
    final user = ref.watch(currentUserProvider);
    final forest = ref.watch(forestProvider);
    
    final displayName =
    user?.nickname?.isNotEmpty == true
        ? user!.nickname!
        : user?.name?.isNotEmpty == true
            ? user!.name!
            : user?.email ?? "조합원";

    final photoUrl = user?.photoUrl;
    final hasPhoto = photoUrl?.isNotEmpty == true;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("건강ON"),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayStepsProvider);
            ref.invalidate(challengeProvider);
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

      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,

      child: !hasPhoto
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

              const TodayStepCard(),

              const SizedBox(height: 24),

              const ForestCard(),

              const SizedBox(height: 24),

              const AiCoachCard(),

              const SizedBox(height: 24),

              const ChallengeProgressSection(),

              //--------------------------------------------------
              // AI 코치
              //--------------------------------------------------

              const AiCoachCard(),

              const SizedBox(height: 24),
              
              const ChallengeProgressSection(), 
              
              const SizedBox(height: 24),

              const TeamCheerCard(),

              const SizedBox(height: 24),

              const FamilyRankingCard(),

              const SizedBox(height: 24),

              const NoticeCard(),

              const SizedBox(height: 30),

              //--------------------------------------------------
              // 빠른 메뉴
              //--------------------------------------------------

              const Text(
                "빠른 메뉴",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              _MenuCard(

icon: Icons.menu_book,

title: "Forest 도감",

subtitle: "나무 컬렉션",

onTap: (){

Navigator.push(

context,

MaterialPageRoute(

builder: (_)=> const ForestBookScreen(),

),

);

},

),
              const SizedBox(height: 16),

              const _QuickMenu(),

              const SizedBox(height: 24),

              //--------------------------------------------------
              // 최근 활동
              //--------------------------------------------------

              const Text(
                "최근 활동",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 16),

              const _RecentActivity(),

              const SizedBox(height: 40),
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
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
