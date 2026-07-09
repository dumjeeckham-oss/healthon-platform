import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("커뮤니티"),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Sprint 6
          // 게시글 작성
        },
        icon: const Icon(Icons.edit),
        label: const Text("응원글 작성"),
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
              "우리 함께 걸어요 👣",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "응원하고 축하하며 함께 목표를 달성해보세요.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 28),

            _CommunityFeed(),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _CommunityFeed extends StatelessWidget {
  const _CommunityFeed();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [

        _FeedCard(
          name: "김광민",
          message: "오늘 드디어 100K 달성했습니다 🎉",
          likes: 28,
          comments: 12,
        ),

        SizedBox(height: 18),

        _FeedCard(
          name: "이영희",
          message: "우리 늘푸른팀 화이팅!! 💚",
          likes: 14,
          comments: 6,
        ),

        SizedBox(height: 18),

        _FeedCard(
          name: "홍길동",
          message: "오늘는 15,000걸음 성공!",
          likes: 9,
          comments: 2,
        ),
      ],
    );
  }
}

class _FeedCard extends StatelessWidget {
  final String name;
  final String message;
  final int likes;
  final int comments;

  const _FeedCard({
    required this.name,
    required this.message,
    required this.likes,
    required this.comments,
  });

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
              children: [

                const CircleAvatar(
                  child: Icon(Icons.person),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        "10분 전",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.red,
                  ),
                ),

                Text("$likes"),

                const SizedBox(width: 18),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                ),

                Text("$comments"),

                const Spacer(),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
