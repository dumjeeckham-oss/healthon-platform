import 'package:flutter/material.dart';

import 'widgets/family_ranking_card.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("가족"),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(
            const Duration(milliseconds: 700),
          );
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [

            Text(
              "우리 가족",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "가족과 함께 건강을 만들어보세요 👨‍👩‍👧",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 28),

            _FamilySummaryCard(),

            SizedBox(height: 24),

            FamilyRankingCard(),

            SizedBox(height: 24),

            _FamilyMembers(),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _FamilySummaryCard extends StatelessWidget {
  const _FamilySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            Text(
              "이번 주 가족 걸음수",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 12),

            Text(
              "58,420",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            SizedBox(height: 6),

            Text("걸음"),

            SizedBox(height: 20),

            LinearProgressIndicator(
              value: .58,
              minHeight: 10,
            ),

            SizedBox(height: 10),

            Text("100,000 걸음 목표"),
          ],
        ),
      ),
    );
  }
}

class _FamilyMembers extends StatelessWidget {
  const _FamilyMembers();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "가족 구성원",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            SizedBox(height: 16),

            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text("김광민"),
              subtitle: Text("오늘 12,340 걸음"),
              trailing: Icon(
                Icons.verified,
                color: Colors.green,
              ),
            ),

            Divider(),

            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text("배우자"),
              subtitle: Text("오늘 8,920 걸음"),
            ),

            Divider(),

            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.child_care),
              ),
              title: Text("첫째"),
              subtitle: Text("오늘 6,540 걸음"),
            ),

            Divider(),

            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.child_care),
              ),
              title: Text("둘째"),
              subtitle: Text("오늘 5,610 걸음"),
            ),

            SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: Icon(Icons.person_add),
                label: Text("가족 초대"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
