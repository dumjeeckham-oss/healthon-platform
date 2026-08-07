/// ===============================================================
/// HealthON — Family Provider (StateNotifier + Optimistic)
/// ===============================================================

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/family_repository.dart';

final familySupabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);
final familyRepoProvider = Provider<FamilyRepository>((ref) => FamilyRepository(ref.watch(familySupabaseProvider)));

// ===============================================================
// Family Notifier
// ===============================================================

class FamilyNotifier extends StateNotifier<AsyncValue<FamilyInfo?>> {
  final FamilyRepository _repo;
  FamilyNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final family = await _repo.getMyFamily();
      state = AsyncValue.data(family);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createFamily({required String name, String description = ''}) async {
    try {
      final family = await _repo.createFamily(name: name, description: description);
      state = AsyncValue.data(family);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> joinFamily(String code) async {
    final success = await _repo.joinFamily(code);
    if (success) await load();
    return success;
  }

  Future<void> leaveFamily(String familyId) async {
    await _repo.leaveFamily(familyId);
    state = const AsyncValue.data(null);
  }
}

final familyProvider = StateNotifierProvider<FamilyNotifier, AsyncValue<FamilyInfo?>>((ref) {
  return FamilyNotifier(ref.watch(familyRepoProvider));
});

// ===============================================================
// Family Members
// ===============================================================

final familyMembersProvider = FutureProvider.family<List<FamilyMemberInfo>, String>((ref, familyId) async {
  if (familyId.isEmpty) return [];
  return ref.watch(familyRepoProvider).getFamilyMembers(familyId);
});

// ===============================================================
// Family Ranking
// ===============================================================

final familyRankingProvider = FutureProvider.family<List<FamilyRankingEntry>, String>((ref, familyId) async {
  if (familyId.isEmpty) return [];
  return ref.watch(familyRepoProvider).getFamilyRanking(familyId);
});

// ===============================================================
// Family Cheers
// ===============================================================

class FamilyCheersNotifier extends StateNotifier<AsyncValue<List<FamilyCheer>>> {
  final FamilyRepository _repo;
  FamilyCheersNotifier(this._repo) : super(const AsyncValue.data([]));

  Future<void> load(String familyId) async {
    try {
      final cheers = await _repo.getCheers(familyId);
      state = AsyncValue.data(cheers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendCheer({required String familyId, required String toUserId, String message = '응원해요! 💪'}) async {
    await _repo.sendCheer(familyId: familyId, toUserId: toUserId, message: message);
    await load(familyId);
  }
}

final familyCheersProvider = StateNotifierProvider<FamilyCheersNotifier, AsyncValue<List<FamilyCheer>>>((ref) {
  return FamilyCheersNotifier(ref.watch(familyRepoProvider));
});
