import 'package:flutter/material.dart';

import '../../domain/models/community_post.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;

  const CommunityPostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //------------------------------------------------------
          // Header
          //------------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [

                const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        _timeAgo(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Chip(
                  label: Text(
                    post.category.name,
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                const Icon(Icons.more_vert),
              ],
            ),
          ),

          //------------------------------------------------------
          // 내용
          //------------------------------------------------------

          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Text(
                post.content,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),

          const SizedBox(height: 16),

          //------------------------------------------------------
          // Forest Snapshot
          //------------------------------------------------------

          if (post.forestSnapshot != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: Row(
                  children: [

                    const Text(
                      "🌳",
                      style: TextStyle(fontSize: 34),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Forest Snapshot",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            post.forestSnapshot.toString(),
                            maxLines: 2,
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

          if (post.forestSnapshot != null)
            const SizedBox(height: 16),

          //------------------------------------------------------
          // Walking Snapshot
          //------------------------------------------------------

          if (post.walkingSnapshot != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: Row(
                  children: [

                    const Text(
                      "🚶",
                      style: TextStyle(fontSize: 34),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Walking Snapshot",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            post.walkingSnapshot.toString(),
                            maxLines: 2,
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

          if (post.walkingSnapshot != null)
            const SizedBox(height: 16),

          //------------------------------------------------------
          // Image Carousel
          //------------------------------------------------------

          if (post.images.isNotEmpty)
            SizedBox(
              height: 300,

              child: PageView.builder(
                itemCount: post.images.length,

                itemBuilder: (_, index) {
                  return Image.network(
                    post.images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

          if (post.images.isNotEmpty)
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return "방금";

    if (diff.inHours < 1) {
      return "${diff.inMinutes}분 전";
    }

    if (diff.inDays < 1) {
      return "${diff.inHours}시간 전";
    }

    return "${diff.inDays}일 전";
  }
}

