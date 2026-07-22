import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/walking_sync_service.dart';

final walkingSyncProvider =
    FutureProvider.autoDispose<void>((ref) async {

  final user =
      Supabase.instance.client.auth.currentUser;

  if (user == null) return;

  final service = WalkingSyncService();

  await service.syncToday(user.id);
});
