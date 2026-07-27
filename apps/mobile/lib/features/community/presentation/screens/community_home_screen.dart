import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/community_post.dart';
import '../providers/community_provider.dart';

class CommunityHomeScreen extends ConsumerStatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  ConsumerState<CommunityHomeScreen> createState() =>
      _CommunityHomeScreenState();
}

class _CommunityHomeScreenState
    extends ConsumerState<CommunityHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final tabs = const [
    ("전체", null),
    ("챌린지", CommunityCategory.challenge),
    ("걷기", CommunityCategory.walking),
    ("숲", CommunityCategory.forest),
    ("건강", CommunityCategory.health),
    ("사진", CommunityCategory.photo),
    ("자유", CommunityCategory.free),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(communityPostsProvider);

    for (final tab in tabs) {
      if (tab.$2 != null) {
        ref.invalidate(
          communityCategoryProvider(tab.$2!),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8F7),

      appBar: AppBar(
        title: const Text(
          "커뮤니티",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: false,

        elevation: 0,

        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs
              .map(
                (e) => Tab(
                  text: e.$1,
                ),
              )
              .toList(),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/community/write",
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text("글쓰기"),
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,

        child: TabBarView(
          controller: _tabController,

          children: tabs.map((tab) {
            if (tab.$2 == null) {
              final asyncPosts =
                  ref.watch(communityPostsProvider);

              return asyncPosts.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),

                error: (e, _) => Center(
                  child: Text(e.toString()),
                ),

                data: (posts) {
                  if (posts.isEmpty) {
                    return const Center(
                      child: Text("게시글이 없습니다."),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount: posts.length,

                    itemBuilder: (_, index) {
                      final post = posts[index];

                      return CommunityPostCard(
                        post: post,
                      );
                    },
                  );
                },
              );
            }

            final asyncPosts = ref.watch(
              communityCategoryProvider(
                tab.$2!,
              ),
            );

            return asyncPosts.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

              error: (e, _) => Center(
                child: Text(e.toString()),
              ),

              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Text("게시글이 없습니다."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: posts.length,

                  itemBuilder: (_, index) {
                    final post = posts[index];

                    return CommunityPostCard(
                      post: post,
                    );
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

///
/// PART2에서 구현
///

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;

  const CommunityPostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
