import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/family_ranking_repository.dart';

/// ===============================================================
///
/// Family Repository
///
/// ===============================================================

final familyRepositoryProvider =
    Provider<FamilyRankingRepository>(
  (ref) => FamilyRankingRepository(),
);

/// ===============================================================
///
/// 가족 랭킹 Provider
///
/// ===============================================================

final familyRankingProvider =
    FutureProvider.autoDispose<List<FamilyRankingUser>>(
  (ref) async {
    final repository =
        ref.read(familyRepositoryProvider);

    return repository.fetchRanking();
  },
);

/// ===============================================================
///
/// 내 순위 Provider
///
/// ===============================================================

final myFamilyRankProvider =
    FutureProvider.autoDispose<FamilyRankingUser?>(
  (ref) async {
    final ranking =
        await ref.watch(familyRankingProvider.future);

    if (ranking.isEmpty) {
      return null;
    }

    return ranking.firstWhere(
      (member) => member.rank > 0,
      orElse: () => ranking.first,
    );
  },
);

/// ===============================================================
///
/// 가족 수 Provider
///
/// ===============================================================

final familyCountProvider =
    FutureProvider.autoDispose<int>(
  (ref) async {
    final ranking =
        await ref.watch(familyRankingProvider.future);

    return ranking.length;
  },
);
