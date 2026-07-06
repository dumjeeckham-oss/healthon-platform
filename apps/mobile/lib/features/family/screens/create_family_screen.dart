import 'dart:math';

import 'package:flutter/material.dart';

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  State<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {

  final TextEditingController _nameController = TextEditingController();

  bool isSaving = false;

  String inviteCode = "";

  @override
  void initState() {
    super.initState();
    inviteCode = _generateInviteCode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _generateInviteCode() {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    final random = Random();

    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> _createFamily() async {

    if (_nameController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("가족 이름을 입력해주세요."),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("가족 생성 완료"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                _nameController.text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              const Text("초대 코드"),

              const SizedBox(height: 8),

              SelectableText(
                inviteCode,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: Colors.green,
                ),
              ),

            ],
          ),
          actions: [

            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("확인"),
            )

          ],
        );
      },
    );

    /// TODO
    /// Supabase family_groups INSERT

    /// TODO
    /// family_members INSERT

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("가족 만들기"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "새로운 가족 그룹",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "가족 이름을 입력하면 초대코드가 생성됩니다.",
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "가족 이름",
                hintText: "예) 행복한 우리집",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.key),
                title: const Text("초대 코드"),
                subtitle: Text(inviteCode),
              ),
            ),

            const SizedBox(height: 30),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [

                    Icon(
                      Icons.info_outline,
                      color: Colors.green,
                      size: 40,
                    ),

                    SizedBox(height: 12),

                    Text(
                      "가족에게 초대코드를 보내면\n"
                      "같은 가족으로 참여할 수 있습니다.",
                      textAlign: TextAlign.center,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: FilledButton(

                onPressed: isSaving
                    ? null
                    : _createFamily,

                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text(
                        "가족 생성하기",
                        style: TextStyle(fontSize: 18),
                      ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}