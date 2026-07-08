import 'package:flutter/material.dart';

class TeamCheerCard extends StatelessWidget {
  const TeamCheerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: const [

                Icon(
                  Icons.groups,
                  color: Colors.green,
                ),

                SizedBox(width: 8),

                Text(
                  "우리 모둠",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: const [

                  CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.flag),
                  ),

                  SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "늘푸른팀",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "이번 주 2위",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.emoji_events,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "모둠 응원",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text("김철수"),
              subtitle: Text("100K 달성 축하합니다! 🎉"),
            ),

            const Divider(),

            const ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text("이영희"),
              subtitle: Text("오늘도 화이팅! 👏"),
            ),

            const Divider(),

            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.favorite),
              label: const Text("응원 보내기"),
            ),
          ],
        ),
      ),
    );
  }
}
