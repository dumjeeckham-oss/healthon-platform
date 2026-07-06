import 'prediction_engine.dart';
import 'decision_engine.dart';

class AiCoachV2 {

  final PredictionEngine predictionEngine;
  final DecisionEngine decisionEngine;

  AiCoachV2(this.predictionEngine, this.decisionEngine);

  String getDailyCoaching(List<int> last7Days) {

    final churnRisk = predictionEngine.isChurnRisk(last7Days);
    final highPotential = predictionEngine.isHighPotential(last7Days);
    final predicted = predictionEngine.predictTomorrowSteps(last7Days);

    return decisionEngine.decide(
      churnRisk: churnRisk,
      highPotential: highPotential,
      predictedSteps: predicted,
    );
  }
}