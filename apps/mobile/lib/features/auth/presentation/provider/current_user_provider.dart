import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import '../../domain/auth_user.dart';

final currentUserProvider = Provider<AuthUser?>((ref) {
  final auth = ref.watch(authProvider);

  return auth.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});
