import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "건강ON",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              child: Icon(Icons.person),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //----------------------------------------------------
            // 인사
            //----------------------------------------------------

            const Text(
              "안녕하세요 👋",
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "오늘도 건강한 하루를 시작해볼까요?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 28),

            //----------------------------------------------------
            // 오늘 걸음수 카드
            //----------------------------------------------------

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [

                  const Text(
                    "오늘 걸음수",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "4,862",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearProgressIndicator(
                      value: 0.48,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "목표 10,000 걸음",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            //----------------------------------------------------
            // 챌린지
            //----------------------------------------------------

            const Text(
              "참여중인 챌린지",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 14),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.flag,
                  color: Colors.green,
                ),
                title: const Text("부천100K 챌린지"),
                subtitle: const Text("48 / 100 km"),
                trailing: FilledButton(
                  onPressed: () {},
                  child: const Text("보기"),
                ),
              ),
            ),

            const SizedBox(height: 28),

            //----------------------------------------------------
            // AI 코치
            //----------------------------------------------------

            const Text(
              "AI 건강코치",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [

                    Icon(
                      Icons.smart_toy,
                      color: Colors.green,
                      size: 42,
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        "오늘은 평소보다 조금 적게 걸으셨네요.\n산책 15분이면 목표에 가까워집니다 😊",
                        style: TextStyle(
                          height: 1.4,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            //----------------------------------------------------
            // 랭킹
            //----------------------------------------------------

            const Text(
              "이번 주 랭킹",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 12),

            ...List.generate(
              5,
              (index) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text("${index + 1}"),
                  ),
                  title: Text("참가자 ${index + 1}"),
                  trailing: Text(
                    "${15000 - index * 1200} 걸음",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,

        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.home),
            label: "홈",
          ),

          NavigationDestination(
            icon: Icon(Icons.flag),
            label: "챌린지",
          ),

          NavigationDestination(
            icon: Icon(Icons.people),
            label: "커뮤니티",
          ),

          NavigationDestination(
            icon: Icon(Icons.person),
            label: "내정보",
          ),
        ],
      ),
    );
  }
}
