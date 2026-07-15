import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import '../../domain/auth_user.dart';

final currentUserProvider = Provider<AuthUser?>((ref) {
  final authState = ref.watch(authProvider);

  return authState.value;
});
