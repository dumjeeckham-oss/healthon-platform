import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/walking_sync_service.dart';
import '../../../challenge/presentation/providers/challenge_provider.dart';

final walkingSyncProvider =
    FutureProvider.autoDispose<void>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) return;

  final syncService = WalkingSyncService();

  await syncService.syncToday(user.id);

  // Challenge 자동 새로고침
  ref.invalidate(challengeProvider);
});
