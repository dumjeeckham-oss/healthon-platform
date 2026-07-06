import '../data/step_repository_impl.dart';

class GetTodaySteps {
  final StepRepositoryImpl repository;

  GetTodaySteps(this.repository);

  Future<int> execute(String userId) async {
    return await repository.getTodaySteps(userId);
  }
}
