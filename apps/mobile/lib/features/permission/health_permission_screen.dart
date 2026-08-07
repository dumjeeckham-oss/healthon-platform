import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../health/presentation/providers/health_provider.dart';

/// ===============================================================
/// HealthON — Health Permission Screen
///
/// 앱 최초 실행 시 Health Connect / Apple Health 권한 요청
/// ===============================================================

class HealthPermissionScreen extends ConsumerStatefulWidget {
  const HealthPermissionScreen({super.key});

  @override
  ConsumerState<HealthPermissionScreen> createState() => _HealthPermissionScreenState();
}

class _HealthPermissionScreenState extends ConsumerState<HealthPermissionScreen> {
  bool _requesting = false;
  String? _error;

  Future<void> _requestPermission() async {
    setState(() {
      _requesting = true;
      _error = null;
    });

    try {
      final hasPermission = await ref.read(healthPermissionProvider.future);

      if (!mounted) return;

      if (hasPermission) {
        // 권한 허용 → 동기화 시작
        final syncNotifier = ref.read(healthSyncProvider.notifier);
        final success = await syncNotifier.sync();

        if (!mounted) return;

        if (success) {
          _showSuccessAndPop();
        } else {
          final syncState = ref.read(healthSyncProvider);
          setState(() {
            _error = syncState.errorMessage ?? '동기화에 실패했습니다';
            _requesting = false;
          });
        }
      } else {
        setState(() {
          _error = 'Health 권한이 거부되었습니다';
          _requesting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '오류가 발생했습니다: $e';
        _requesting = false;
      });
    }
  }

  void _showSuccessAndPop() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('건강 데이터 동기화가 완료되었습니다 🎉'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _skipForNow() {
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = Platform.isAndroid;
    final deviceName = isAndroid ? 'Health Connect' : 'Apple Health';
    final icon = isAndroid ? Icons.health_and_safety : Icons.favorite;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 56, color: const Color(0xFF2E7D32)),
                ),

                const SizedBox(height: 28),

                // Title
                const Text(
                  '걸음 데이터를\n연결해주세요',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  '$deviceName의 걸음 데이터를\n건강ON과 연동하면\n걷기만 해도 Forest가 자라고\nChallenge가 완료됩니다',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Feature bullets
                _FeatureBullet(
                  icon: Icons.park_outlined,
                  text: 'Forest Tree 자동 성장',
                ),
                _FeatureBullet(
                  icon: Icons.emoji_events_outlined,
                  text: 'Challenge 자동 진행',
                ),
                _FeatureBullet(
                  icon: Icons.leaderboard_outlined,
                  text: 'Ranking 실시간 반영',
                ),
                _FeatureBullet(
                  icon: Icons.task_alt_outlined,
                  text: 'Mission 자동 완료',
                ),

                const SizedBox(height: 36),

                // Error
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 18, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Allow button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _requesting ? null : _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _requesting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '허용하고 시작하기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Skip
                TextButton(
                  onPressed: _requesting ? null : _skipForNow,
                  child: const Text(
                    '나중에 설정하기',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF616161))),
        ],
      ),
    );
  }
}
