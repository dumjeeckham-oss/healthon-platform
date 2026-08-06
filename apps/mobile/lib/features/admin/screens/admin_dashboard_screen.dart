import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../admin_provider.dart';

/// ===============================================================
/// HealthON — 관리자 대시보드 화면 v2
///
/// StateNotifierProvider 기반. 통계 카드 13개 + 주간 차트 2개
/// ===============================================================

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminDashboardProvider.notifier).load();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(adminDashboardProvider.notifier).load();
    // FutureProvider chart들도 강제 갱신
    ref.invalidate(adminWeeklyStepsChartProvider);
    ref.invalidate(adminDailyUsersChartProvider);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminDashboardProvider);
    final stepsChartAsync = ref.watch(adminWeeklyStepsChartProvider);
    final usersChartAsync = ref.watch(adminDailyUsersChartProvider);

    final isWide = MediaQuery.of(context).size.width > 800;
    const accent = Color(0xFF2E7D32);
    const dark = Color(0xFF1E1E2D);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: accent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 헤더 ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '대시보드',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '오늘의 HealthON 현황을 한눈에 확인하세요',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  color: accent,
                  tooltip: '새로고침',
                  onPressed: _onRefresh,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── 통계 카드 그리드 ──
            statsAsync.when(
              loading: () => const _LoadingGrid(),
              error: (err, st) => _ErrorCard(message: err.toString()),
              data: (stats) => _StatsGrid(
                stats: stats,
                isWide: isWide,
                accent: accent,
                dark: dark,
              ),
            ),
            const SizedBox(height: 32),

            // ── 주간 걸음 차트 ──
            _ChartSection(
              title: '주간 걸음 수',
              asyncValue: stepsChartAsync,
              accent: accent,
              dark: dark,
              valueLabel: '걸음',
              isWide: isWide,
            ),
            const SizedBox(height: 24),

            // ── 일간 활성 사용자 차트 ──
            _ChartSection(
              title: '일간 활성 사용자',
              asyncValue: usersChartAsync,
              accent: accent,
              dark: dark,
              valueLabel: '명',
              isWide: isWide,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 로딩 그리드
// ===============================================================

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// ===============================================================
// 통계 카드 그리드 (오늘 통계 8개 + 개요 통계 5개 = 13개)
// ===============================================================

class _StatsGrid extends StatelessWidget {
  final AdminDashboardStats stats;
  final bool isWide;
  final Color accent;
  final Color dark;

  const _StatsGrid({
    required this.stats,
    required this.isWide,
    required this.accent,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      // ── 오늘 통계 (8개) ──
      _StatItem('오늘 가입', stats.todaySignups, Icons.person_add, const Color(0xFF1565C0)),
      _StatItem('오늘 로그인', stats.todayLogins, Icons.login, const Color(0xFF0277BD)),
      _StatItem('오늘 걸음수', stats.todaySteps, Icons.directions_walk, const Color(0xFFE65100)),
      _StatItem('Forest 성장', stats.todayForestGrowth, Icons.forest, const Color(0xFF2E7D32)),
      _StatItem('챌린지 완료', stats.todayChallengeCompletions, Icons.emoji_events, const Color(0xFFF9A825)),
      _StatItem('미션 완료', stats.todayMissionCompletions, Icons.assignment_turned_in, const Color(0xFF6A1B9A)),
      _StatItem('게시글', stats.todayPosts, Icons.article, const Color(0xFF00838F)),
      _StatItem('댓글', stats.todayComments, Icons.chat_bubble_outline, const Color(0xFFAD1457)),
      // ── 전체 개요 (5개) ──
      _StatItem('전체 회원', stats.totalUsers, Icons.people, const Color(0xFF1E1E2D)),
      _StatItem('활동 회원', stats.activeUsers, Icons.person, accent),
      _StatItem('정지 회원', stats.suspendedUsers, Icons.block, stats.suspendedUsers > 0 ? Colors.red : Colors.grey),
      _StatItem('진행 챌린지', stats.activeChallenges, Icons.flag, const Color(0xFFFF8F00)),
      _StatItem('대기 신고', stats.pendingReports, Icons.report, stats.pendingReports > 0 ? Colors.red[700]! : Colors.grey),
    ];

    final crossAxisCount = isWide ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _StatCard(item: item, dark: dark);
      },
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final IconData icon;
  final Color iconColor;

  const _StatItem(this.label, this.value, this.icon, this.iconColor);
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  final Color dark;

  const _StatCard({required this.item, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, size: 20, color: item.iconColor),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _formatNumber(item.value),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: dark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}천';
    return n.toString();
  }
}

// ===============================================================
// 차트 섹션
// ===============================================================

class _ChartSection extends StatelessWidget {
  final String title;
  final AsyncValue<AdminChartData> asyncValue;
  final Color accent;
  final Color dark;
  final String valueLabel;
  final bool isWide;

  const _ChartSection({
    required this.title,
    required this.asyncValue,
    required this.accent,
    required this.dark,
    required this.valueLabel,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: dark,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: asyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '차트 로드 실패',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ),
                ),
                data: (chartData) => _buildLineChart(chartData),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(AdminChartData data) {
    if (data.labels.isEmpty) {
      return Center(
        child: Text('데이터가 없습니다', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
      );
    }

    final spots = <FlSpot>[];
    double maxY = 0;
    for (int i = 0; i < data.values.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.values[i]));
      if (data.values[i] > maxY) maxY = data.values[i];
    }
    // 최대값이 0이면 최소 y축 범위 보장
    if (maxY == 0) maxY = 10;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[200]!,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data.labels[idx],
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatAxisValue(value),
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: accent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(radius: 4, color: accent, strokeWidth: 2, strokeColor: Colors.white),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: accent.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: maxY * 1.15,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()} $valueLabel',
                  const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _formatAxisValue(double value) {
    if (value >= 10000) return '${(value / 10000).toStringAsFixed(1)}만';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}천';
    return value.toInt().toString();
  }
}

// ===============================================================
// 에러 카드
// ===============================================================

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[50],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
