import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/walking_sync_service.dart';

final walkingSyncProvider =
    Provider<WalkingSyncService>((ref) {
  return WalkingSyncService();
});
