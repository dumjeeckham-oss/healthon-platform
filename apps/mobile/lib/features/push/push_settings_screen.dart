/// ===============================================================
/// HealthON — Push Notification Settings Screen
///
/// 푸시 설정 화면 (마이페이지 → 알림 설정)
/// ===============================================================

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'push_provider.dart';

class PushSettingsScreen extends ConsumerStatefulWidget {
  const PushSettingsScreen({super.key});

  @override
  ConsumerState<PushSettingsScreen> createState() => _PushSettingsScreenState();
}

class _PushSettingsScreenState extends ConsumerState<PushSettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(pushSettingsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(pushSettingsProvider);
    final notifier = ref.read(pushSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 전체 푸시
            Card(
              child: SwitchListTile(
                title: const Text('푸시 알림', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                subtitle: const Text('모든 푸시 알림을 켜거나 끕니다'),
                value: settings.pushEnabled,
                onChanged: (v) => notifier.togglePushEnabled(v),
                activeThumbColor: const Color(0xFF2E7D32),
              ),
            ),

            if (settings.pushEnabled) ...[
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('수신할 알림', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black54)),
              ),

              _CategoryTile(
                icon: Icons.campaign,
                title: '공지사항',
                subtitle: '법인소식, 이벤트, 교육 알림',
                value: settings.noticePush,
                onChanged: (v) => notifier.toggleCategory('notice_push', v),
              ),
              _CategoryTile(
                icon: Icons.emoji_events,
                title: '챌린지',
                subtitle: '새 챌린지 시작, 완주, 보상 알림',
                value: settings.challengePush,
                onChanged: (v) => notifier.toggleCategory('challenge_push', v),
              ),
              _CategoryTile(
                icon: Icons.assignment,
                title: '미션',
                subtitle: '일일/주간 미션, 완료 알림',
                value: settings.missionPush,
                onChanged: (v) => notifier.toggleCategory('mission_push', v),
              ),
              _CategoryTile(
                icon: Icons.forest,
                title: 'Forest',
                subtitle: '나무 성장, 시즌 변경 알림',
                value: settings.forestPush,
                onChanged: (v) => notifier.toggleCategory('forest_push', v),
              ),
              _CategoryTile(
                icon: Icons.forum,
                title: '커뮤니티',
                subtitle: '댓글, 좋아요, 멘션 알림',
                value: settings.communityPush,
                onChanged: (v) => notifier.toggleCategory('community_push', v),
              ),
              _CategoryTile(
                icon: Icons.card_giftcard,
                title: '리워드',
                subtitle: '포인트 적립, 쿠폰 발급 알림',
                value: settings.rewardPush,
                onChanged: (v) => notifier.toggleCategory('reward_push', v),
              ),
              _CategoryTile(
                icon: Icons.report,
                title: '신고 처리',
                subtitle: '신고 결과 알림',
                value: settings.reportPush,
                onChanged: (v) => notifier.toggleCategory('report_push', v),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // 방해금지 시간
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('방해금지 시간', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        settings.quietHoursEnabled
                            ? '${settings.quietHoursStart} ~ ${settings.quietHoursEnd}'
                            : '설정 안 함',
                      ),
                      value: settings.quietHoursEnabled,
                      onChanged: (v) {
                        final updated = settings.copyWith(quietHoursEnabled: v);
                        ref.read(pushSettingsProvider.notifier).update(updated);
                      },
                      activeThumbColor: const Color(0xFF2E7D32),
                    ),
                    if (settings.quietHoursEnabled)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TimePicker(
                                label: '시작',
                                time: settings.quietHoursStart,
                                onChanged: (t) {
                                  final updated = settings.copyWith(quietHoursStart: t);
                                  ref.read(pushSettingsProvider.notifier).update(updated);
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('~', style: TextStyle(fontSize: 20)),
                            ),
                            Expanded(
                              child: _TimePicker(
                                label: '종료',
                                time: settings.quietHoursEnd,
                                onChanged: (t) {
                                  final updated = settings.copyWith(quietHoursEnd: t);
                                  ref.read(pushSettingsProvider.notifier).update(updated);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 80),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('설정을 불러올 수 없습니다: $err')),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(icon, color: value ? const Color(0xFF2E7D32) : Colors.grey),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF2E7D32),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final String time;
  final ValueChanged<String> onChanged;

  const _TimePicker({required this.label, required this.time, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final parts = time.split(':');
        final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        final picked = await showTimePicker(context: context, initialTime: initialTime);
        if (picked != null) {
          onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
