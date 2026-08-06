/// ===============================================================
/// HealthON Phase 9 — AI Settings Screen
///
/// AI 알림 설정 화면
/// ===============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AISettingsScreen extends ConsumerStatefulWidget {
  const AISettingsScreen({super.key});

  @override
  ConsumerState<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends ConsumerState<AISettingsScreen> {
  bool _morningMotivation = true;
  bool _goalAchieved = true;
  bool _churnRisk = true;
  bool _streakMilestone = true;
  bool _forestGrowth = true;
  bool _weeklyReport = true;
  bool _challengeReminder = true;
  bool _healthTips = false;
  double _quietStart = 22;
  double _quietEnd = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 알림 설정'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 알림 토글
          const Text('📬 알림 종류',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('AI 코치가 보내는 알림을 설정하세요',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 12),

          _SettingTile(
            icon: Icons.wb_sunny,
            title: '아침 동기부여',
            subtitle: '오전 8시, 오늘의 목표와 응원 메시지',
            value: _morningMotivation,
            onChanged: (v) => setState(() => _morningMotivation = v),
          ),

          _SettingTile(
            icon: Icons.emoji_events,
            title: '목표 달성 축하',
            subtitle: '일일 목표 달성 시 축하 메시지',
            value: _goalAchieved,
            onChanged: (v) => setState(() => _goalAchieved = v),
          ),

          _SettingTile(
            icon: Icons.warning_amber,
            title: '이탈 위험 경고',
            subtitle: '걸음이 부족할 때 동기부여 알림',
            value: _churnRisk,
            onChanged: (v) => setState(() => _churnRisk = v),
          ),

          _SettingTile(
            icon: Icons.local_fire_department,
            title: '연속 기록 마일스톤',
            subtitle: '3일/7일/30일 연속 걸음 달성 시',
            value: _streakMilestone,
            onChanged: (v) => setState(() => _streakMilestone = v),
          ),

          _SettingTile(
            icon: Icons.forest,
            title: 'Forest 성장 알림',
            subtitle: '나무 레벨업 임박 시 알림',
            value: _forestGrowth,
            onChanged: (v) => setState(() => _forestGrowth = v),
          ),

          _SettingTile(
            icon: Icons.assessment,
            title: '주간 리포트',
            subtitle: '매주 월요일 오전 10시 활동 리포트',
            value: _weeklyReport,
            onChanged: (v) => setState(() => _weeklyReport = v),
          ),

          _SettingTile(
            icon: Icons.emoji_events_outlined,
            title: '챌린지 리마인더',
            subtitle: '진행 중인 챌린지 진행률 알림',
            value: _challengeReminder,
            onChanged: (v) => setState(() => _challengeReminder = v),
          ),

          _SettingTile(
            icon: Icons.tips_and_updates,
            title: '건강 팁',
            subtitle: '걷기/건강 관련 유용한 팁 (주 1~2회)',
            value: _healthTips,
            onChanged: (v) => setState(() => _healthTips = v),
          ),

          const SizedBox(height: 24),

          // 방해 금지 시간
          const Text('🌙 방해 금지 시간',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('이 시간대에는 AI 알림이 오지 않아요',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('시작', style: TextStyle(fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${_quietStart.round()}시',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  Slider(
                    value: _quietStart,
                    min: 20,
                    max: 23,
                    divisions: 3,
                    activeColor: const Color(0xFF2E7D32),
                    label: '${_quietStart.round()}시',
                    onChanged: (v) => setState(() => _quietStart = v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('종료', style: TextStyle(fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${_quietEnd.round()}시',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  Slider(
                    value: _quietEnd,
                    min: 5,
                    max: 10,
                    divisions: 5,
                    activeColor: const Color(0xFF2E7D32),
                    label: '${_quietEnd.round()}시',
                    onChanged: (v) => setState(() => _quietEnd = v),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 저장 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('AI 알림 설정이 저장되었습니다 ✅'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('설정 저장',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SwitchListTile(
        secondary: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2E7D32),
      ),
    );
  }
}
