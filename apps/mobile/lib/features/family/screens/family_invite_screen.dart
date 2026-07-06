import 'package:flutter/material.dart';

class FamilyInviteScreen extends StatefulWidget {
  const FamilyInviteScreen({super.key});

  @override
  State<FamilyInviteScreen> createState() => _FamilyInviteScreenState();
}

class _FamilyInviteScreenState extends State<FamilyInviteScreen> {

  final TextEditingController inviteController =
      TextEditingController();

  bool joining = false;

  @override
  void dispose() {
    inviteController.dispose();
    super.dispose();
  }

  Future<void> joinFamily() async {

    final code = inviteController.text.trim();

    if (code.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("초대코드를 입력해주세요."),
        ),
      );

      return;
    }

    setState(() {
      joining = true;
    });

    // TODO
    // Supabase family_groups 조회
    // invite_code == code

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      joining = false;
    });

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text("가족 참여 완료"),

          content: const Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              Icon(
                Icons.favorite,
                color: Colors.green,
                size: 70,
              ),

              SizedBox(height: 15),

              Text(
                "가족 그룹에\n성공적으로 참여했습니다.",
                textAlign: TextAlign.center,
              ),

            ],

          ),

          actions: [

            FilledButton(

              onPressed: (){

                Navigator.pop(context);

                Navigator.pop(context);

              },

              child: const Text("확인"),

            )

          ],

        );

      },

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("가족 참여"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            const Text(

              "초대코드를 입력하세요",

              style: TextStyle(

                fontSize: 24,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 10),

            const Text(

              "가족에게 받은 초대코드를 입력하면\n같은 가족으로 참여합니다.",

            ),

            const SizedBox(height: 40),

            TextField(

              controller: inviteController,

              textCapitalization:
                  TextCapitalization.characters,

              decoration: const InputDecoration(

                labelText: "초대코드",

                hintText: "ABC123",

                border: OutlineInputBorder(),

                prefixIcon: Icon(Icons.key),

              ),

            ),

            const SizedBox(height: 25),

            Card(

              color: Colors.orange.shade50,

              child: const Padding(

                padding: EdgeInsets.all(16),

                child: Row(

                  children: [

                    Icon(Icons.info),

                    SizedBox(width: 12),

                    Expanded(

                      child: Text(

                        "초대코드는 가족을 만든 사람이\n공유한 6자리 코드입니다.",

                      ),

                    )

                  ],

                ),

              ),

            ),

            const SizedBox(height: 30),

            Card(

              child: ListTile(

                leading: const Icon(Icons.qr_code),

                title: const Text("QR 코드로 참여"),

                subtitle:
                    const Text("다음 버전에서 지원 예정"),

                trailing: FilledButton(

                  onPressed: (){

                  },

                  child: const Text("준비중"),

                ),

              ),

            ),

            const SizedBox(height: 40),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: FilledButton(

                onPressed: joining
                    ? null
                    : joinFamily,

                child: joining

                    ? const CircularProgressIndicator()

                    : const Text(

                        "가족 참여하기",

                        style: TextStyle(
                          fontSize: 18,
                        ),

                      ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}