import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('건강ON'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '안녕하세요 👋',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '건강ON MVP 홈 화면입니다.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_walk),
                title: const Text('오늘 걸음 수'),
                subtitle: const Text('Health Connect 연동 예정'),
                trailing: const Text(
                  '0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text('100K 챌린지'),
                subtitle: const Text('진행률 계산 예정'),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.family_restroom),
                title: const Text('가족 랭킹'),
                subtitle: const Text('Sprint 3에서 연결'),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.smart_toy),
                title: const Text('AI 건강 코치'),
                subtitle: const Text('Sprint 4에서 연결 예정'),
              ),
            ),

            const SizedBox(height: 40),

            FilledButton(
              onPressed: () {
                context.go('/');
              },
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
