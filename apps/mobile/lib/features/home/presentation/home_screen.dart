import 'package:flutter/material.dart';

import '../../ai/ai_coach_service.dart';
import '../../walking/data/step_repository_impl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AiCoachService _aiService;

  String _message = "오늘의 건강 상태를 분석하는 중...";

  /// TODO
  ///
  /// 실제 로그인 기능이 완성되면
  /// 현재 로그인된 사용자 ID를 가져오도록 변경
  ///
  static const String demoUserId = "demo-user";

  @override
  void initState() {
    super.initState();

    _aiService = AiCoachService(
      StepRepositoryImpl(),
    );

    _loadMessage();
  }

  Future<void> _loadMessage() async {
    try {
      final result =
          await _aiService.getDailyMessage(demoUserId);

      if (!mounted) return;

      setState(() {
        _message = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _message = "오늘의 메시지를 불러오지 못했습니다.";
      });

      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("건강ON"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
