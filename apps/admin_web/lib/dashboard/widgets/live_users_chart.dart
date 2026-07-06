import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveUsersChart extends StatefulWidget {
  const LiveUsersChart({super.key});

  @override
  State<LiveUsersChart> createState() => _LiveUsersChartState();
}

class _LiveUsersChartState extends State<LiveUsersChart> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> chartData = [];

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    supabase
        .from('step_daily')
        .stream(primaryKey: ['id'])
        .listen((data) {
      final Map<String, int> dailyUsers = {};

      for (final row in data) {
        final date = row['date'];
        final user = row['user_id'];

        final key = date.toString();
        dailyUsers[key] = (dailyUsers[key] ?? 0) + 1;
      }

      setState(() {
        chartData = dailyUsers.entries
            .map((e) => {
                  "date": e.key,
                  "users": e.value,
                })
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 250,
        child: Center(
          child: Text(
            "📊 실시간 사용자 변화\n${chartData.length} data points",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}