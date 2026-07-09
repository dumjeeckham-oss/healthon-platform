import 'package:flutter/material.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/challenge/presentation/challenge_screen.dart';
import '../features/family/presentation/family_screen.dart';
import '../features/community/presentation/community_screen.dart';
import '../features/mypage/presentation/my_page_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  late final List<Widget> pages = const [
    const HomeScreen(),
    const ChallengeScreen(),
    const FamilyScreen(),
    const CommunityScreen(),
    const MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
       height: 70,
       backgroundColor: Colors.white,
       indicatorColor: Colors.green.shade100,
       labelBehavior:
       NavigationDestinationLabelBehavior.alwaysShow,

       selectedIndex: currentIndex,

       onDestinationSelected: (index) {
       setState(() {
       currentIndex = index;
    });
  },

  destinations: const [

          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "홈",
          ),

          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk),
            label: "챌린지",
          ),

          NavigationDestination(
            icon: Icon(Icons.family_restroom_outlined),
            selectedIcon: Icon(Icons.family_restroom),
            label: "가족",
          ),

          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: "커뮤니티",
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "마이",
          ),
        ],
      ),
    );
  }
}

class _ChallengePage extends StatelessWidget {
  const _ChallengePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "챌린지 화면\n(Sprint 4)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _FamilyPage extends StatelessWidget {
  const _FamilyPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "가족 화면\n(Sprint 5)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _CommunityPage extends StatelessWidget {
  const _CommunityPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "커뮤니티 화면\n(Sprint 6)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _MyPage extends StatelessWidget {
  const _MyPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "마이페이지\n(Sprint 7)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
