import 'package:flutter/material.dart';

import '../../domain/models/community_post.dart';

class CommunityPostCard extends StatefulWidget {
  final CommunityPost post;

  const CommunityPostCard({
    super.key,
    required this.post,
  });

  @override
  State<CommunityPostCard> createState() =>
      _CommunityPostCardState();
}

class _CommunityPostCardState
    extends State<CommunityPostCard> {

  late final PageController _pageController;

  int currentImage = 0;

  bool liked = false;

  bool bookmarked = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final post = widget.post;

    return Card(

      margin: const EdgeInsets.only(
        bottom: 20,
      ),

      elevation: 0,

      clipBehavior: Clip.antiAlias,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          //----------------------------------------------------
          // Header
          //----------------------------------------------------

          Padding(

            padding:
                const EdgeInsets.all(18),

            child: Row(

              children: [

                const CircleAvatar(

                  radius: 24,

                  child: Icon(
                    Icons.person,
                  ),

                ),

                const SizedBox(width: 14),

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        post.title,

                        style: const TextStyle(

                          fontWeight:
                              FontWeight.bold,

                          fontSize: 17,

                        ),

                      ),

                      const SizedBox(height: 3),

                      Text(

                        _timeAgo(
                          post.createdAt,
                        ),

                        style: TextStyle(

                          color:
                              Colors.grey.shade600,

                          fontSize: 12,

                        ),

                      ),

                    ],

                  ),

                ),

                Chip(

                  label: Text(
                    post.category.name,
                  ),

                ),

                const SizedBox(width: 8),

                PopupMenuButton(

                  itemBuilder: (_) => [

                    const PopupMenuItem(

                      value: "report",

                      child: Text("신고"),

                    ),

                    const PopupMenuItem(

                      value: "share",

                      child: Text("공유"),

                    ),

                  ],

                ),

              ],

            ),

          ),

          //----------------------------------------------------
          // Content
          //----------------------------------------------------

          if(post.content.isNotEmpty)

          Padding(

            padding: const EdgeInsets.symmetric(

              horizontal:18,

            ),

            child: Text(

              post.content,

              style: const TextStyle(

                fontSize:15,

              ),

            ),

          ),

          const SizedBox(height:16),

          //----------------------------------------------------
          // Forest Snapshot
          //----------------------------------------------------

          if(post.forestSnapshot!=null)

          Padding(

            padding: const EdgeInsets.symmetric(

              horizontal:18,

            ),

            child: Container(

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color:
                    Colors.green.shade50,

                borderRadius:

                    BorderRadius.circular(18),

              ),

              child: Row(

                children: [

                  const Text(

                    "🌳",

                    style: TextStyle(

                      fontSize:34,

                    ),

                  ),

                  const SizedBox(width:12),

                  Expanded(

                    child: Column(

                      crossAxisAlignment:

                          CrossAxisAlignment.start,

                      children: [

                        const Text(

                          "Forest",

                          style: TextStyle(

                            fontWeight:

                                FontWeight.bold,

                          ),

                        ),

                        Text(

                          post.forestSnapshot
                              .toString(),

                          maxLines:2,

                          overflow:
                              TextOverflow.ellipsis,

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            ),

          ),

          if(post.forestSnapshot!=null)

          const SizedBox(height:16),

          //----------------------------------------------------
          // Walking Snapshot
          //----------------------------------------------------

          if(post.walkingSnapshot!=null)

          Padding(

            padding: const EdgeInsets.symmetric(

              horizontal:18,

            ),

            child: Container(

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color:
                    Colors.orange.shade50,

                borderRadius:

                    BorderRadius.circular(18),

              ),

              child: Row(

                children: [

                  const Text(

                    "🚶",

                    style: TextStyle(

                      fontSize:34,

                    ),

                  ),

                  const SizedBox(width:12),

                  Expanded(

                    child: Column(

                      crossAxisAlignment:

                          CrossAxisAlignment.start,

                      children: [

                        const Text(

                          "Walking",

                          style: TextStyle(

                            fontWeight:

                                FontWeight.bold,

                          ),

                        ),

                        Text(

                          post.walkingSnapshot
                              .toString(),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            ),

          ),

          if(post.walkingSnapshot!=null)

          const SizedBox(height:16),

                    //----------------------------------------------------
          // Image Carousel
          //----------------------------------------------------

          if (post.images.isNotEmpty)
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: post.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentImage = index;
                      });
                    },
                    itemBuilder: (_, index) {
                      return Hero(
                        tag: "${post.id}-$index",
                        child: Image.network(
                          post.images[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),

                  //------------------------------------------------
                  // Page Indicator
                  //------------------------------------------------

                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: List.generate(
                        post.images.length,
                        (index) => AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 250),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                          width: currentImage == index ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentImage == index
                                ? Colors.white
                                : Colors.white54,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (post.images.isNotEmpty)
            const SizedBox(height: 12),

          //----------------------------------------------------
          // Action Buttons
          //----------------------------------------------------

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      liked = !liked;
                    });
                  },
                  icon: Icon(
                    liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        liked ? Colors.red : Colors.grey.shade700,
                  ),
                ),

                Text(
                  "${post.likeCount + (liked ? 1 : 0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 12),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mode_comment_outlined,
                  ),
                ),

                Text(
                  "${post.commentCount}",
                ),

                const SizedBox(width: 12),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share_outlined,
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: () {
                    setState(() {
                      bookmarked = !bookmarked;
                    });
                  },
                  icon: Icon(
                    bookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          //----------------------------------------------------
          // Like Text
          //----------------------------------------------------

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "좋아요 ${post.likeCount + (liked ? 1 : 0)}개",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          
