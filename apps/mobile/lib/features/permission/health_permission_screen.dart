import 'package:flutter/material.dart';

class HealthPermissionScreen extends StatelessWidget {
  const HealthPermissionScreen({super.key});

  Future<void> _requestPermission() async {
    // Health Connect / HealthKit 요청 연결 자리
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.favorite,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                "걸음 데이터를 허용해주세요",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                "건강ON은 사용자의 걸음을\n건강 데이터로 변환합니다",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () async {
                  await _requestPermission();
                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
                child: const Text("허용하기"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
