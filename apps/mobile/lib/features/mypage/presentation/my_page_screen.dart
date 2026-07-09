import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("마이페이지"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          //-------------------------------------------------
          // 프로필
          //-------------------------------------------------

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [

                  const CircleAvatar(
                    radius: 35,
                    child: Icon(
                      Icons.person,
                      size: 38,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: const [

                        Text(
                          "김광민",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          "healthon@email.com",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          //-------------------------------------------------
          // 내 기록
          //-------------------------------------------------

          const Text(
            "내 활동",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const _InfoTile(
            icon: Icons.directions_walk,
            title: "오늘 걸음",
            value: "8,240 걸음",
          ),

          const _InfoTile(
            icon: Icons.route,
            title: "누적 거리",
            value: "428 km",
          ),

          const _InfoTile(
            icon: Icons.emoji_events,
            title: "완주 횟수",
            value: "7 회",
          ),

          const SizedBox(height: 28),

          //-------------------------------------------------
          // 설정
          //-------------------------------------------------

          const Text(
            "설정",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _MenuTile(
            icon: Icons.family_restroom,
            title: "가족 관리",
            onTap: () {},
          ),

          _MenuTile(
            icon: Icons.favorite,
            title: "Health Connect",
            onTap: () {},
          ),

          _MenuTile(
            icon: Icons.notifications,
            title: "알림 설정",
            onTap: () {},
          ),

          _MenuTile(
            icon: Icons.settings,
            title: "앱 설정",
            onTap: () {},
          ),

          _MenuTile(
            icon: Icons.info_outline,
            title: "앱 정보",
            onTap: () {},
          ),

          const SizedBox(height: 30),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // TODO
              // 로그아웃
            },
            icon: const Icon(Icons.logout),
            label: const Text("로그아웃"),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
