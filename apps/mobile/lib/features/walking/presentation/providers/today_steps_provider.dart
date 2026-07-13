import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../health/presentation/providers/health_provider.dart';

final todayStepsProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(healthRepositoryProvider);

  return repository.getTodaySteps();
});
