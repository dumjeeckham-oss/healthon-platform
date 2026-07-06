import 'package:flutter/material.dart';

import '../services/realtime_service.dart';

import 'widgets/live_users_chart.dart';
import 'widgets/steps_trend_chart.dart';
import 'widgets/activity_rate_chart.dart';
import 'widgets/anomaly_alert_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RealtimeService service = RealtimeService();

  int totalUsers = 0;
  int activeUsers = 0;
  int totalSteps = 0;
  double activeRate = 0.0;

  List<String> inactiveUsers = [];

  @override
  void initState() {
    super.initState();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    service.streamStats().listen((data) {
      if (!mounted) return;

      setState(() {
        totalUsers = data["totalUsers"] ?? 0;
        activeUsers = data["activeUsers"] ?? 0;
        totalSteps = data["totalSteps"] ?? 0;
        activeRate = data["activeRate"] ?? 0.0;

        // ⚠️ 현재는 service에서 아직 안 주므로 임시 안전값
        inactiveUsers = [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HealthON Admin OPS Center"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // =========================
              // KPI SECTION (기존 핵심)
              // =========================
              _buildKpiCard("전체 사용자", "$totalUsers 명"),
              _buildKpiCard("활성 사용자", "$activeUsers 명"),
              _buildKpiCard("전체 걸음", "$totalSteps 보"),
              _buildKpiCard(
                "활동률",
                "${(activeRate * 100).toStringAsFixed(1)}%",
              ),

              const SizedBox(height: 20),

              // =========================
              // REALTIME CHARTS
              // =========================
              const Text(
                "📊 실시간 운영 그래프",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const LiveUsersChart(),
              const SizedBox(height: 12),

              const StepsTrendChart(),
              const SizedBox(height: 12),

              ActivityRateChart(rate: activeRate),

              const SizedBox(height: 20),

              // =========================
              // ANOMALY ALERT
              // =========================
              AnomalyAlertWidget(
                inactiveUsers: inactiveUsers,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // KPI CARD WIDGET
  // =========================
  Widget _buildKpiCard(String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}