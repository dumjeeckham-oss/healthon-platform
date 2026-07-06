import 'package:flutter/material.dart';

class FamilyHomeScreen extends StatefulWidget {
  const FamilyHomeScreen({super.key});

  @override
  State<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends State<FamilyHomeScreen> {

  final List<FamilyMember> members = [
    FamilyMember(
      name: "엄마",
      steps: 10542,
      avatar: "👩",
    ),
    FamilyMember(
      name: "아빠",
      steps: 8745,
      avatar: "👨",
    ),
    FamilyMember(
      name: "나",
      steps: 6932,
      avatar: "🧑",
    ),
    FamilyMember(
      name: "할머니",
      steps: 4156,
      avatar: "👵",
    ),
  ];

  @override
  Widget build(BuildContext context) {

    members.sort((a,b)=>b.steps.compareTo(a.steps));

    final totalSteps =
        members.fold<int>(0, (sum, e) => sum + e.steps);

    return Scaffold(

      appBar: AppBar(
        title: const Text("우리 가족"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //------------------------------------------------
            // 가족 요약
            //------------------------------------------------

            Card(

              elevation: 3,

              child: Padding(

                padding: const EdgeInsets.all(20),

                child: Column(

                  children: [

                    const Text(
                      "👨‍👩‍👧‍👦 우리 가족",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "${members.length}명 참여중",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "오늘 총 ${_comma(totalSteps)}보",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //------------------------------------------------
            // 주간 미션
            //------------------------------------------------

            const Text(
              "이번 주 가족 미션",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              color: Colors.green.shade50,
              child: const ListTile(
                leading: Icon(Icons.flag),
                title: Text("가족 총 70,000보 걷기"),
                subtitle: Text("달성하면 가족 배지를 획득합니다."),
              ),
            ),

            const SizedBox(height: 20),

            //------------------------------------------------
            // 가족 랭킹
            //------------------------------------------------

            const Text(
              "오늘의 가족 랭킹",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ListView.builder(

              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              itemCount: members.length,

              itemBuilder: (_, index){

                final m = members[index];

                return Card(

                  child: ListTile(

                    leading: CircleAvatar(

                      child: Text(m.avatar),

                    ),

                    title: Text(m.name),

                    subtitle: Text("${_comma(m.steps)} 보"),

                    trailing: _rankMedal(index),

                  ),

                );

              },

            ),

            const SizedBox(height: 20),

            //------------------------------------------------
            // AI 코칭
            //------------------------------------------------

            Card(

              color: Colors.orange.shade50,

              child: const Padding(

                padding: EdgeInsets.all(16),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      "🤖 AI 가족 코치",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "오늘은 가족 전체가 아주 좋은 활동량을 보이고 있어요!\n"
                      "저녁 산책 15분만 더 하면 이번 주 목표를 달성할 가능성이 높습니다.",
                    ),

                  ],

                ),

              ),

            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              child: FilledButton.icon(

                onPressed: (){

                },

                icon: const Icon(Icons.group_add),

                label: const Text("가족 초대"),

              ),

            ),

          ],

        ),

      ),

    );

  }

  Widget _rankMedal(int rank){

    switch(rank){

      case 0:
        return const Text("🥇",style: TextStyle(fontSize: 28));

      case 1:
        return const Text("🥈",style: TextStyle(fontSize: 28));

      case 2:
        return const Text("🥉",style: TextStyle(fontSize: 28));

      default:
        return Text("${rank+1}위");
    }

  }

  String _comma(int number){

    final text = number.toString();

    final buffer = StringBuffer();

    for(int i=0;i<text.length;i++){

      final position=text.length-i;

      buffer.write(text[i]);

      if(position>1 && position%3==1){

        buffer.write(",");

      }

    }

    return buffer.toString();

  }

}

class FamilyMember{

  final String name;

  final int steps;

  final String avatar;

  FamilyMember({

    required this.name,

    required this.steps,

    required this.avatar,

  });

}