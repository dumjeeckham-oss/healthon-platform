import '../../ai/ai_coach_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String message = "로딩 중...";

  late AiCoachService aiService;

  @override
  void initState() {
    super.initState();
    aiService = AiCoachService(/* repository 주입 */);
    _loadMessage();
  }

  Future<void> _loadMessage() async {
    final result = await aiService.getDailyMessage("user_id");
    setState(() {
      message = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}