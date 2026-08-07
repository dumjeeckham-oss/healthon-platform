/// ===============================================================
/// HealthON — Analytics Dashboard Screen
///
/// DAU/WAU/MAU + 트렌드 차트 + 카테고리 분포 + 챌린지 퍼널
/// ===============================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics_provider.dart';
import '../analytics_repository.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(analyticsSummaryProvider);
    final trend = ref.watch(analyticsTrendProvider);
    final catDist = ref.watch(analyticsCategoryDistProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsSummaryProvider);
        ref.invalidate(analyticsTrendProvider);
        ref.invalidate(analyticsCategoryDistProvider);
      },
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('HealthON Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(ref.watch(analyticsSummaryProvider).whenOrNull(data: (s) => '마지막 업데이트: ${DateTime.now().toIso8601String().substring(0, 10)}') ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        const SizedBox(height: 20),

        // === 핵심 지표 ===
        summary.when(
          data: (s) => _KpiGrid(summary: s),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('지표 로드 실패')),
        ),
        const SizedBox(height: 20),

        // === DAU/신규 트렌드 ===
        Card(
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📈 DAU & 신규 가입 트렌드 (30일)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(height: 220, child: trend.when(
              data: (points) => _TrendChart(points: points),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text('차트 로드 실패')),
            )),
          ])),
        ),
        const SizedBox(height: 16),

        // === 걸음수 트렌드 ===
        Card(
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🚶 일별 걸음 수 추이', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: trend.when(
              data: (points) => _StepsBarChart(points: points),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text('차트 로드 실패')),
            )),
          ])),
        ),
        const SizedBox(height: 16),

        // === 카테고리 분포 ===
        Card(
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📊 커뮤니티 카테고리 분포 (30일)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: catDist.when(
              data: (cats) => _CategoryPieChart(cats: cats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text('차트 로드 실패')),
            )),
          ])),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }
}

// ===============================================================
// KPI Grid
// ===============================================================

class _KpiGrid extends StatelessWidget {
  final AnalyticsSummary summary;
  const _KpiGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return GridView.count(
      crossAxisCount: isWide ? 5 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: [
        _KpiCard(title: 'DAU', value: '${_f(summary.dau)}', subtitle: '오늘 활성'),
        _KpiCard(title: 'WAU', value: '${_f(summary.wau)}', subtitle: '주간 활성'),
        _KpiCard(title: 'MAU', value: '${_f(summary.mau)}', subtitle: '월간 활성'),
        _KpiCard(title: 'DAU/MAU', value: '${(summary.dauMauRatio * 100).toStringAsFixed(1)}%', subtitle: '고착도', color: summary.dauMauRatio >= 0.3 ? Colors.green : Colors.orange),
        _KpiCard(title: '전체 회원', value: '${_f(summary.totalUsers)}', subtitle: '누적'),
        _KpiCard(title: '평균 걸음', value: '${_f(summary.avgStepsPerUser.round())}', subtitle: '/인', color: summary.avgStepsPerUser >= 7000 ? Colors.green : Colors.orange),
        _KpiCard(title: '도전 완주율', value: '${(summary.challengeCompletionRate * 100).toStringAsFixed(1)}%', subtitle: '챌린지'),
        _KpiCard(title: '참여율', value: '${(summary.engagementRate * 100).toStringAsFixed(1)}%', subtitle: '게시글+댓글/DAU'),
        _KpiCard(title: '주간 성장', value: '${(summary.weeklyGrowth * 100).toStringAsFixed(1)}%', subtitle: 'DAU 증감', color: summary.weeklyGrowth >= 0 ? Colors.green : Colors.red),
        _KpiCard(title: '1주 리텐션', value: '${(summary.retentionWeek1 * 100).toStringAsFixed(1)}%', subtitle: '재방문율'),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title, value, subtitle;
  final Color? color;
  const _KpiCard({required this.title, required this.value, required this.subtitle, this.color});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    child: Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color ?? const Color(0xFF1E1E2D))),
      Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ])),
  );
}

// ===============================================================
// Trend Line Chart (DAU + New Users)
// ===============================================================

class _TrendChart extends StatelessWidget {
  final List<TrendPoint> points;
  const _TrendChart({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Center(child: Text('데이터 없음'));
    final maxVal = points.map((p) => p.dau > p.newUsers ? p.dau : p.newUsers).reduce((a, b) => a > b ? a : b).toDouble();

    return LineChart(LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxVal / 4),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (v, _) => Text('${v ~/ 1}', style: const TextStyle(fontSize: 10)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 7, getTitlesWidget: (v, _) {
          final idx = v.toInt();
          if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
          return Text('${points[idx].date.month}/${points[idx].date.day}', style: const TextStyle(fontSize: 9));
        })),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minY: 0, maxY: maxVal * 1.15,
      lineBarsData: [
        LineChartBarData(
          spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.dau.toDouble())).toList(),
          isCurved: true, color: const Color(0xFF2E7D32), barWidth: 3, dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: const Color(0xFF2E7D32).withOpacity(0.08)),
        ),
        LineChartBarData(
          spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.newUsers.toDouble())).toList(),
          isCurved: true, color: Colors.orange, barWidth: 2, dotData: const FlDotData(show: false),
        ),
      ],
    ));
  }
}

// ===============================================================
// Steps Bar Chart
// ===============================================================

class _StepsBarChart extends StatelessWidget {
  final List<TrendPoint> points;
  const _StepsBarChart({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Center(child: Text('데이터 없음'));
    final maxVal = points.map((p) => p.steps).reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(BarChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60, getTitlesWidget: (v, _) => Text('${(v / 1000).round()}k', style: const TextStyle(fontSize: 10)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 7, getTitlesWidget: (v, _) {
          final idx = v.toInt();
          if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
          return Text('${points[idx].date.month}/${points[idx].date.day}', style: const TextStyle(fontSize: 9));
        })),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      maxY: maxVal * 1.1,
      barGroups: points.asMap().entries.map((e) => BarChartGroupData(
        x: e.key,
        barRods: [BarChartRodData(toY: e.value.steps.toDouble(), color: const Color(0xFF2E7D32), width: 8)],
      )).toList(),
    ));
  }
}

// ===============================================================
// Category Pie Chart
// ===============================================================

class _CategoryPieChart extends StatelessWidget {
  final List<CategoryDist> cats;
  const _CategoryPieChart({required this.cats});

  static const _colors = [Color(0xFF2E7D32), Color(0xFF43A047), Color(0xFF66BB6A), Color(0xFFA5D6A7), Color(0xFFFF9800), Color(0xFF2196F3), Color(0xFF9C27B0), Color(0xFF607D8B), Color(0xFF795548)];

  @override
  Widget build(BuildContext context) {
    if (cats.isEmpty) return const Center(child: Text('데이터 없음'));
    return Row(children: [
      Expanded(flex: 3, child: PieChart(PieChartData(
        sections: cats.asMap().entries.map((e) => PieChartSectionData(
          value: e.value.count.toDouble(),
          title: '${e.value.label}\n${e.value.count}',
          color: _colors[e.key % _colors.length],
          radius: 70, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
        )).toList(),
        centerSpaceRadius: 0,
      ))),
      Expanded(flex: 2, child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: cats.take(6).map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: _colors[cats.indexOf(c) % _colors.length], shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(child: Text(c.label, style: const TextStyle(fontSize: 11))),
          Text('${c.count}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
        ]))).toList(),
      )),
    ]);
  }
}

String _f(int v) => v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
