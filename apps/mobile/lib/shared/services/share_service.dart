import 'package:flutter/services.dart';

class ShareService {
  static const String appName = "건강ON";

  static Future<void> shareChallenge({
    required String challengeName,
    required double progress,
    required double totalKm,
  }) async {
    final percent = ((progress / totalKm) * 100).clamp(0, 100).toStringAsFixed(0);

    final message = """
🌳 $appName 함께 걷기

🏆 $challengeName

📊 진행률: $percent%

🚶 함께 건강을 만들어가요!

#건강ON #걷기챌린지
""";

    await Clipboard.setData(ClipboardData(text: message));
  }

  static Future<void> shareBadge({
    required String badgeName,
  }) async {
    final message = """
🏅 $appName 배지 획득!

✨ $badgeName 달성!

함께 건강을 만들어가는 중입니다 🌿

#건강ON
""";

    await Clipboard.setData(ClipboardData(text: message));
  }
}
