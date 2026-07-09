import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/provider/current_user_provider.dart';
import '../data/step_repository_impl.dart';

final todayStepProvider =
    FutureProvider<int>((ref) async {
  final user =
      ref.watch(currentUserProvider);

  if (user == null) return 0;

  final repository = StepRepositoryImpl();

  return repository.getTodaySteps(user.id);
});
