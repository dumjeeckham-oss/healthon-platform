import '../data/step_repository_impl.dart';

class SyncSteps {
  final StepRepositoryImpl repository;

  SyncSteps(this.repository);

  Future<void> execute({
    required String userId,
    required int steps,
    required double distanceKm,
  }) async {

    await repository.saveDailySteps(
      userId: userId,
      date: DateTime.now(),
      steps: steps,
      distanceKm: distanceKm,
    );
  }
}
