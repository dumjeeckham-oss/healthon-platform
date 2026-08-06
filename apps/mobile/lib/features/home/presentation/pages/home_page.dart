import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../health/presentation/providers/health_provider.dart';
import '../widgets/challenge_card.dart';
import '../widgets/greeting_card.dart';
import '../widgets/today_steps_card.dart';
import '../widgets/forest_card.dart';

/// ===============================================================
/// Home Page — health_daily Provider 통합
/// ===============================================================

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 시 Health Sync 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSync();
    });
  }

  Future<void> _ensureSync() async {
    // 권한 확인
    final hasPermission = await ref.read(healthPermissionProvider.future);
    if (!hasPermission) return;

    // 동기화 실행 (첫 실행이면 permission screen 타고 왔을 것)
    final syncState = ref.read(healthSyncProvider);
    if (syncState.state == HealthSyncState.idle) {
      ref.read(healthSyncProvider.notifier).sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(healthSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('건강ON'),
        actions: [
          // Sync status indicator
          if (syncState.state == HealthSyncState.syncing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(healthTodayProvider);
            ref.invalidate(healthWeekProvider);
            ref.invalidate(healthMonthProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              GreetingCard(name: '홍길동'),
              SizedBox(height: 16),
              ChallengeCard(),
              SizedBox(height: 16),
              TodayStepsCard(),
              SizedBox(height: 16),
              ForestCard(),
            ],
          ),
        ),
      ),
    );
  }
}
