import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StepsTrendChart extends StatefulWidget {
  const StepsTrendChart({super.key});

  @override
  State<StepsTrendChart> createState() => _StepsTrendChartState();
}

class _StepsTrendChartState extends State<StepsTrendChart> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> trend = [];

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
      final Map<String, int> stepsByDate = {};

      for (final row in data) {
        final date = row['date'];
        final steps = row['steps'] ?? 0;

        final key = date.toString();
        stepsByDate[key] = (stepsByDate[key] ?? 0) + steps;
      }

      setState(() {
        trend = stepsByDate.entries
            .map((e) => {
                  "date": e.key,
                  "steps": e.value,
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
            "👣 걸음 트렌드\n${trend.length} points",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}