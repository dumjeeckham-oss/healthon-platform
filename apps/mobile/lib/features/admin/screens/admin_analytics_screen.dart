import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../admin_provider.dart';

/// ===============================================================
/// HealthON — Analytics 화면
///
/// DAU / WAU / MAU / Retention / Forest / Challenge / Mission
/// 게시글 / 댓글 통계 + fl_chart 시각화
/// ===============================================================

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  int _dauDays = 7;

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(adminAnalyticsOverviewProvider);
    final dauChartAsync = ref.watch(adminDAUChartProvider(_dauDays));
    final retentionChartAsync = ref.watch(adminRetentionChartProvider);
    final postsChartAsync = ref.watch(adminPostsCommentsChartProvider(7));

    final isWide = MediaQuery.of(context).size.width > 800;
    const accent = Color(0xFF2E7D32);
    const dark = Color(0xFF1E1E2D);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPI 카드 ──
          overviewAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => _ErrorBanner(message: err.toString()),
            data: (overview) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KpiGrid(overview: overview, isWide: isWide, accent: accent, dark: dark),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── DAU 차트 ──
          _ChartCard(
            title: '일간 활성 사용자 (DAU)',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [7, 14, 30].map((d) {
                final selected = _dauDays == d;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ChoiceChip(
                    label: Text('${d}일', style: TextStyle(fontSize: 11, color: selected ? Colors.white : dark)),
                    selected: selected,
                    selectedColor: accent,
                    onSelected: (_) => setState(() => _dauDays = d),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }).toList(),
            ),
            height: 240,
            asyncValue: dauChartAsync,
            accent: accent,
            labelSuffix: '명',
          ),
          const SizedBox(height: 24),

          // ── Retention 차트 ──
          _ChartCard(
            title: '리텐션 (Retention)',
            height: 240,
            asyncValue: retentionChartAsync,
            accent: const Color(0xFF6A1B9A),
            labelSuffix: '%',
          ),
          const SizedBox(height: 24),

          // ── 게시글 트렌드 ──
          _ChartCard(
            title: '주간 게시글 추이',
            height: 240,
            asyncValue: postsChartAsync,
            accent: const Color(0xFF00838F),
            labelSuffix: '건',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ===============================================================
// KPI Grid
// ===============================================================

class _KpiGrid extends StatelessWidget {
  final AnalyticsOverview overview;
  final bool isWide;
  final Color accent;
  final Color dark;

  const _KpiGrid({
    required this.overview,
    required this.isWide,
    required this.accent,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _KpiItem('DAU', overview.dau, Icons.today, const Color(0xFF1565C0), '오늘'),
      _KpiItem('WAU', overview.wau, Icons.date_range, const Color(0xFF2E7D32), '주간'),
      _KpiItem('MAU', overview.mau, Icons.calendar_month, const Color(0xFF6A1B9A), '월간'),
      _KpiItem('총 사용자', overview.totalUsers, Icons.people, const Color(0xFF1E1E2D), '누적'),
      _KpiItem('전체 게시글', overview.totalPosts, Icons.article, const Color(0xFF00838F), '누적'),
      _KpiItem('전체 댓글', overview.totalComments, Icons.chat_bubble, const Color(0xFFAD1457), '누적'),
      _KpiItem('Challenge 완료율', (overview.challengeCompletionRate * 100).round(), Icons.emoji_events, const Color(0xFFF9A825), '%'),
      _KpiItem('Mission 완료율', (overview.missionCompletionRate * 100).round(), Icons.assignment_turned_in, const Color(0xFFE65100), '%'),
    ];

    final crossAxisCount = isWide ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, size: 18, color: item.color),
                    ),
                    const Spacer(),
                    Text(item.subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatNumber(item.value),
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: dark),
                    ),
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(item.suffix, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ),
                  ],
                ),
                Text(item.label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}천';
    return n.toString();
  }
}

class _KpiItem {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final String suffix;

  const _KpiItem(this.label, this.value, this.icon, this.color, this.subtitle, [this.suffix = '']);
}

// ===============================================================
// Chart Card
// ===============================================================

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final double height;
  final AsyncValue<AdminChartData> asyncValue;
  final Color accent;
  final String labelSuffix;

  const _ChartCard({
    required this.title,
    this.trailing,
    this.height = 240,
    required this.asyncValue,
    required this.accent,
    required this.labelSuffix,
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
            Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: asyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(
                  child: Text('데이터 로드 실패', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
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
      return Center(child: Text('데이터가 없습니다', style: TextStyle(color: Colors.grey[500])));
    }

    final spots = <FlSpot>[];
    double maxY = 0;
    for (int i = 0; i < data.values.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.values[i]));
      if (data.values[i] > maxY) maxY = data.values[i];
    }
    if (maxY == 0) maxY = 10;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
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
                  child: Text(data.labels[idx], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
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
            belowBarData: BarAreaData(show: true, color: accent.withOpacity(0.1)),
          ),
        ],
        minY: 0,
        maxY: maxY * 1.2,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()} $labelSuffix',
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
// Error Banner
// ===============================================================

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

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
            Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13))),
          ],
        ),
      ),
    );
  }
}
