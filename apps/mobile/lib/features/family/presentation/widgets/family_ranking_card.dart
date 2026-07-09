import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../provider/family_provider.dart';

class FamilyRankingCard extends ConsumerWidget {
  const FamilyRankingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(familyRankingProvider);

    return rankingAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '가족 랭킹을 불러오지 못했습니다.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (ranking) {
        if (ranking.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text("가족 그룹에 참여된 구성원이 없습니다."),
              ),
            ),
          );
        }

        final currentUserId =
            Supabase.instance.client.auth.currentUser?.id;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.family_restroom,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "가족 랭킹",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ...ranking.map((member) {
                  final isMe = member.id == currentUserId;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,

                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      backgroundImage:
                          member.photoUrl != null &&
                                  member.photoUrl!.isNotEmpty
                              ? NetworkImage(member.photoUrl!)
                              : null,
                      child: member.photoUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),

                    title: Row(
                      children: [
                        Text(member.name),

                        if (isMe)
                          Container(
                            margin:
                                const EdgeInsets.only(left: 8),
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "나",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),

                    subtitle: Text(
                      "${member.totalSteps.toString()} 걸음",
                    ),

                    trailing: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          member.rank == 1
                              ? Colors.amber
                              : Colors.grey.shade300,
                      child: Text(
                        "${member.rank}",
                        style: TextStyle(
                          color: member.rank == 1
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 10),

                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(
                        familyRankingProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("새로고침"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
