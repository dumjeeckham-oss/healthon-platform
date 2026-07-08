import 'package:flutter/material.dart';

import '../../ai/presentation/widgets/ai_coach_card.dart';
import '../../walking/presentation/widgets/today_step_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [

              //--------------------------------------------------
              // 인사말
              //--------------------------------------------------

              Text(
                "안녕하세요 👋",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 6),

              Text(
                "오늘도 건강한 하루를 시작해보세요.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: 28),

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
      children: const [
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
        children: const [
          ListTile(
            leading: Icon(Icons.directions_walk),
            title: Text("오늘 7,820걸음 달성"),
            subtitle: Text("10분 전"),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.emoji_events),
            title: Text("100K 챌린지 참여"),
            subtitle: Text("어제"),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text("AI 코치 응원 메시지 도착"),
            subtitle: Text("어제"),
          ),
        ],
      ),
    );
  }
}
