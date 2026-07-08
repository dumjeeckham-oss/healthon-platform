import 'package:flutter/material.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key});

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
                  Icons.campaign,
                  color: Colors.green,
                ),

                SizedBox(width: 8),

                Text(
                  "공지사항",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Spacer(),

                Icon(Icons.chevron_right),
              ],
            ),

            const SizedBox(height: 20),

            const _NoticeItem(
              title: "7월 건강걷기 이벤트 시작",
              date: "2026.07.01",
              important: true,
            ),

            Divider(),

            const _NoticeItem(
              title: "100K 챌린지 완주자 상품 안내",
              date: "2026.06.30",
            ),

            Divider(),

            const _NoticeItem(
              title: "건강ON 앱 업데이트 안내",
              date: "2026.06.28",
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  // TODO
                  // 공지사항 전체보기
                },
                icon: const Icon(Icons.list),
                label: const Text("전체 공지 보기"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeItem extends StatelessWidget {
  final String title;
  final String date;
  final bool important;

  const _NoticeItem({
    required this.title,
    required this.date,
    this.important = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        if (important)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "공지",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                date,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
