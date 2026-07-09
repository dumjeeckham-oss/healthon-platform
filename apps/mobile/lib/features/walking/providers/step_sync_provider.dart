import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/health_repository.dart';
import '../data/step_repository_impl.dart';
import '../services/services/step_sync_service.dart';

final healthRepositoryProvider =
    Provider<HealthRepository>(
  (ref) => HealthRepository(),
);

final stepRepositoryProvider =
    Provider<StepRepositoryImpl>(
  (ref) => StepRepositoryImpl(),
);

final stepSyncServiceProvider =
    Provider<StepSyncService>(
  (ref) => StepSyncService(
    healthRepository:
        ref.read(healthRepositoryProvider),
    stepRepository:
        ref.read(stepRepositoryProvider),
  ),
);
