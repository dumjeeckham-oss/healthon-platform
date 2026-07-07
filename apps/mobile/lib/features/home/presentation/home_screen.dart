import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ai/ai_coach_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AiCoachService _aiService = const AiCoachService();

  String _message = "AI 건강 코치가 오늘의 메시지를 준비 중입니다...";

  @override
  void initState() {
    super.initState();
    _loadMessage();
  }

  Future<void> _loadMessage() async {
    final result = await _aiService.getDailyMessage("demo-user");

    if (!mounted) return;

    setState(() {
      _message = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("건강ON"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "안녕하세요 👋",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "건강ON MVP에 오신 것을 환영합니다.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_walk),
                title: const Text("오늘 걸음 수"),
                subtitle: const Text("Health Connect 연동 예정"),
                trailing: const Text(
                  "0",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.flag),
                title: const Text("100K 챌린지"),
                subtitle: const Text("진행률 계산 예정"),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.family_restroom),
                title: const Text("가족 랭킹"),
                subtitle: const Text("Sprint 3에서 구현"),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.smart_toy),
                        SizedBox(width: 8),
                        Text(
                          "AI 건강 코치",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _message,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            FilledButton.icon(
              onPressed: () {
                context.go('/');
              },
              icon: const Icon(Icons.logout),
              label: const Text("로그아웃"),
            ),
          ],
        ),
      ),
    );
  }
}
