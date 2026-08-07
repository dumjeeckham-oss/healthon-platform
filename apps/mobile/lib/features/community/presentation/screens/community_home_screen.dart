import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/community_post.dart';
import '../providers/community_provider.dart';
import '../widgets/community_post_card.dart';

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

  //----------------------------------------------------
  // Scroll
  //----------------------------------------------------

  final ScrollController _scrollController = ScrollController();

  //----------------------------------------------------
  // Search
  //----------------------------------------------------

  final TextEditingController _searchController =
      TextEditingController();

  bool _searchActive = false;

  //----------------------------------------------------
  // Feed Filter
  //----------------------------------------------------

  int _selectedFilterIndex = 0;

  static const List<Map<String, String>> _feedFilters = [
    {'label': '전체', 'icon': '🌿'},
    {'label': 'Forest', 'icon': '🌳'},
    {'label': 'Walking', 'icon': '🚶'},
    {'label': 'Mission', 'icon': '🎯'},
    {'label': 'Challenge', 'icon': '🔥'},
    {'label': 'Badge', 'icon': '🏅'},
    {'label': '공지', 'icon': '📢'},
    {'label': '추천', 'icon': '⭐'},
    {'label': '내 글', 'icon': '📝'},
  ];

  //----------------------------------------------------
  // Pagination
  //----------------------------------------------------

  bool _isLoadingMore = false;

  static const int _pageSize = 10;

  //----------------------------------------------------
  // Story mock
  //----------------------------------------------------

  static const List<Map<String, String>> _stories = [
    {'icon': '🌱', 'label': '오늘 심기', 'type': 'forest'},
    {'icon': '🚶', 'label': '오늘 걸음', 'type': 'walking'},
    {'icon': '🎯', 'label': '오늘 미션', 'type': 'mission'},
    {'icon': '🏅', 'label': '새 배지', 'type': 'badge'},
    {'icon': '🔥', 'label': '챌린지', 'type': 'challenge'},
    {'icon': '👤', 'label': '프로필', 'type': 'profile'},
  ];

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
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ===========================================================
  // Scroll → infinite
  // ===========================================================

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
    });

    // TODO — real pagination via provider
    await Future<void>.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
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

      //----------------------------------------------------
      // ⑥ FAB — SpeedDial
      //----------------------------------------------------

      floatingActionButton: _FabSpeedDial(
        onWrite: () {
          Navigator.pushNamed(context, '/community/write');
        },
        onForestShare: () {
          Navigator.pushNamed(context, '/community/write');
        },
        onWalkingShare: () {
          Navigator.pushNamed(context, '/community/write');
        },
        onPhoto: () {
          Navigator.pushNamed(context, '/community/write');
        },
        onChallenge: () {
          Navigator.pushNamed(context, '/community/write');
        },
      ),

      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            //------------------------------------------------
            // ① SliverAppBar
            //------------------------------------------------

            SliverAppBar(
              title: const Text(
                '커뮤니티',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: false,
              elevation: 0,
              pinned: true,
              floating: false,
              snap: false,
              expandedHeight: 120,
              collapsedHeight: kToolbarHeight + kTextTabBarHeight,
              backgroundColor: const Color(0xFF2E7D32),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF2E7D32),
                        Color(0xFF4CAF50),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Align(
                    alignment:
                        const Alignment(0, 0.5),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 16),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: const [
                          Text(
                            '🌳',
                            style: TextStyle(fontSize: 32),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'HealthON',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize:
                    const Size.fromHeight(
                        kTextTabBarHeight + 8),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          Colors.white70,
                      tabs: tabs
                          .map((e) => Tab(text: e.$1))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },

        body: Column(
          children: [
            //------------------------------------------------
            // ④ Search Bar
            //------------------------------------------------

            _SearchBarWidget(
              controller: _searchController,
              searchActive: _searchActive,
              onTap: () {
                setState(() {
                  _searchActive = true;
                });
              },
              onChanged: (v) {
                setState(() {
                  // _searchQuery removed
                });
              },
              onClose: () {
                setState(() {
                  _searchActive = false;
                  _searchController.clear();
                });
              },
            ),

            const SizedBox(height: 4),

            //------------------------------------------------
            // ② Story Section
            //------------------------------------------------

            const _StorySection(stories: _stories),

            const SizedBox(height: 4),

            //------------------------------------------------
            // ③ Feed Filter
            //------------------------------------------------

            _FeedFilterRow(
              filters: _feedFilters,
              selectedIndex: _selectedFilterIndex,
              onSelected: (i) {
                setState(() {
                  _selectedFilterIndex = i;
                });
              },
            ),

            //------------------------------------------------
            // Tab View
            //------------------------------------------------

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:
                    tabs.map((tab) {
                  final bool isAll = tab.$2 == null;

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: _FeedList(
                      tab: tab,
                      isLoadingMore: _isLoadingMore,
                      onScroll: _onScroll,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// ⑥ FAB SpeedDial
// ===============================================================

class _FabSpeedDial extends StatefulWidget {
  final VoidCallback onWrite;
  final VoidCallback onForestShare;
  final VoidCallback onWalkingShare;
  final VoidCallback onPhoto;
  final VoidCallback onChallenge;

  const _FabSpeedDial({
    required this.onWrite,
    required this.onForestShare,
    required this.onWalkingShare,
    required this.onPhoto,
    required this.onChallenge,
  });

  @override
  State<_FabSpeedDial> createState() => _FabSpeedDialState();
}

class _FabSpeedDialState extends State<_FabSpeedDial>
    with SingleTickerProviderStateMixin {
  bool _open = false;

  late final AnimationController _ac;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotate = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _ac, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      _open ? _ac.forward() : _ac.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _FabItem(
            label: '챌린지',
            icon: Icons.emoji_events,
            delayMs: 0,
            onTap: () {
              _toggle();
              widget.onChallenge();
            },
          ),
          _FabItem(
            label: '사진',
            icon: Icons.camera_alt_outlined,
            delayMs: 50,
            onTap: () {
              _toggle();
              widget.onPhoto();
            },
          ),
          _FabItem(
            label: '걷기 공유',
            icon: Icons.directions_walk,
            delayMs: 100,
            onTap: () {
              _toggle();
              widget.onWalkingShare();
            },
          ),
          _FabItem(
            label: 'Forest 공유',
            icon: Icons.park,
            delayMs: 150,
            onTap: () {
              _toggle();
              widget.onForestShare();
            },
          ),
          _FabItem(
            label: '글쓰기',
            icon: Icons.edit,
            delayMs: 200,
            onTap: () {
              _toggle();
              widget.onWrite();
            },
          ),
          const SizedBox(height: 8),
        ],

        RotationTransition(
          turns: _rotate,
          child: FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: const Color(0xFF2E7D32),
            child: Icon(
              _open ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _FabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final int delayMs;
  final VoidCallback onTap;

  const _FabItem({
    required this.label,
    required this.icon,
    required this.delayMs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FadeTransition(
        opacity: const AlwaysStoppedAnimation(1.0),
        child: SlideTransition(
          position: const AlwaysStoppedAnimation(Offset.zero),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                heroTag: 'fab_$label',
                onPressed: onTap,
                backgroundColor: Colors.white,
                child: Icon(
                  icon,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// ④ Search Bar
// ===============================================================

class _SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool searchActive;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const _SearchBarWidget({
    required this.controller,
    required this.searchActive,
    required this.onTap,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: searchActive
            ? TextField(
                key: const ValueKey('search_active'),
                controller: controller,
                autofocus: true,
                onChanged: onChanged,
                cursorColor: const Color(0xFF2E7D32),
                decoration: InputDecoration(
                  hintText: '닉네임, 해시태그, 본문 검색',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF2E7D32),
                    size: 20,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: onClose,
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF2E7D32)
                          .withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              )
            : GestureDetector(
                key: const ValueKey('search_inactive'),
                onTap: onTap,
                child: Container(
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '검색',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ===============================================================
// ② Story Section
// ===============================================================

class _StorySection extends StatelessWidget {
  final List<Map<String, String>> stories;

  const _StorySection({required this.stories});

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final Map<String, String> s = stories[i];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50)
                          .withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    s['icon'] ?? '🌱',
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s['label'] ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ===============================================================
// ③ Feed Filter
// ===============================================================

class _FeedFilterRow extends StatelessWidget {
  final List<Map<String, String>> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FeedFilterRow({
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final Map<String, String> f = filters[i];
          final bool isSelected = i == selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2E7D32)
                                .withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      f['icon'] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      f['label'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===============================================================
// ⑦ Feed List (common for all tabs)
// ===============================================================

class _FeedList extends ConsumerWidget {
  final (String, CommunityCategory?) tab;
  final bool isLoadingMore;
  final VoidCallback onScroll;

  const _FeedList({
    required this.tab,
    required this.isLoadingMore,
    required this.onScroll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAll = tab.$2 == null;

    final AsyncValue<List<CommunityPost>> asyncPosts = isAll
        ? ref.watch(communityPostsProvider)
        : ref.watch(communityCategoryProvider(tab.$2!));

    return asyncPosts.when(
      //----------------------------------------------------------
      // ⑧ Skeleton Loading
      //----------------------------------------------------------

      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) =>
            const _SkeletonCard(),
      ),

      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                '오류가 발생했습니다',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                e.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),

      data: (posts) {
        //--------------------------------------------------------
        // ⑥ Empty Screen
        //--------------------------------------------------------

        if (posts.isEmpty) {
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                onScroll();
              }
              return false;
            },
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context)
                          .size.height *
                      0.55,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🌳',
                          style: TextStyle(
                            fontSize: 64,
                            color: Colors.green.shade200,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 게시글이 없어요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '첫 번째 게시글을 작성해보세요!\n미션을 완료하고 Forest를 키워보세요 🌱',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        //--------------------------------------------------------
        // ⑦ Feed + Infinite Scroll
        //--------------------------------------------------------

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              onScroll();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                posts.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (_, index) {
              // --- loading indicator at bottom ---

              if (index == posts.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                );
              }

              final post = posts[index];

              // --- Hero-enabled card ---

              return Hero(
                tag: 'post_${post.id}',
                child: CommunityPostCard(post: post),
              );
            },
          ),
        );
      },
    );
  }
}

// ===============================================================
// ⑧ Skeleton Card (Shimmer placeholder)
// ===============================================================

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 160,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 100,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// ⑤ Helper — Always-Complete Animation
// ===============================================================

class _AlwaysCompleteAnimation extends Animation<double> {
  const _AlwaysCompleteAnimation();

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void addStatusListener(AnimationStatusListener listener) {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}

  @override
  AnimationStatus get status => AnimationStatus.completed;

  @override
  double get value => 1.0;
}
