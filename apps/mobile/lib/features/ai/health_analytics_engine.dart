/// ===============================================================
/// HealthON Phase 9 — Health Analytics Engine
///
/// 심층 건강 데이터 분석
/// - 추세 분석 (7일, 30일, 90일)
/// - 이상 감지 (Anomaly Detection)
/// - BMI/칼로리 추정
/// - 활동 점수 계산
/// - 비교 분석 (동년배, 전체 유저 대비)
/// ===============================================================

library;

import 'dart:math';

class HealthAnalyticsEngine {
  // =============================================================
  // 활동 점수 (0-100)
  // =============================================================

  int calculateActivityScore({
    required List<int> stepsLast7Days,
    required List<int> stepsLast30Days,
    required int streak,
  }) {
    double score = 0;

    // 1. 최근 7일 평균 (40%)
    if (stepsLast7Days.isNotEmpty) {
      final avg7 = stepsLast7Days.reduce((a, b) => a + b) / stepsLast7Days.length;
      score += (avg7 / 10000).clamp(0.0, 1.0) * 40;
    }

    // 2. 일관성 (30%)
    if (stepsLast7Days.length >= 3) {
      final mean = stepsLast7Days.reduce((a, b) => a + b) / stepsLast7Days.length;
      final variance = stepsLast7Days.map((s) => pow(s - mean, 2)).reduce((a, b) => a + b) / stepsLast7Days.length;
      final stdDev = sqrt(variance);
      final consistency = (1.0 - (stdDev / max(mean, 1.0))).clamp(0.0, 1.0);
      score += consistency * 30;
    }

    // 3. 연속 기록 (20%)
    score += (streak / 21).clamp(0.0, 1.0) * 20;

    // 4. 30일 트렌드 (10%)
    if (stepsLast30Days.length >= 14) {
      final firstHalf = stepsLast30Days.take(14).toList();
      final secondHalf = stepsLast30Days.skip(max(0, stepsLast30Days.length - 14)).toList();
      final firstAvg = firstHalf.isNotEmpty ? firstHalf.reduce((a, b) => a + b) / firstHalf.length : 0.0;
      final secondAvg = secondHalf.isNotEmpty ? secondHalf.reduce((a, b) => a + b) / secondHalf.length : 0.0;
      if (firstAvg > 0) {
        final trend = ((secondAvg - firstAvg) / firstAvg).clamp(-0.5, 0.5);
        score += ((trend + 0.5) / 1.0) * 10;
      }
    }

    return score.round().clamp(0, 100);
  }

  // =============================================================
  // 이상 감지 (Anomaly Detection)
  // =============================================================

  AnomalyResult detectAnomaly(List<int> dailySteps, {double threshold = 2.0}) {
    if (dailySteps.length < 7) {
      return const AnomalyResult(hasAnomaly: false, anomalyDays: []);
    }

    final mean = dailySteps.reduce((a, b) => a + b) / dailySteps.length;
    final variance = dailySteps.map((s) => pow(s - mean, 2)).reduce((a, b) => a + b) / dailySteps.length;
    final stdDev = sqrt(variance);

    if (stdDev == 0) return const AnomalyResult(hasAnomaly: false, anomalyDays: []);

    final anomalyDays = <int>[];
    for (int i = 0; i < dailySteps.length; i++) {
      final zScore = (dailySteps[i] - mean).abs() / stdDev;
      if (zScore > threshold) {
        anomalyDays.add(i);
      }
    }

    return AnomalyResult(
      hasAnomaly: anomalyDays.isNotEmpty,
      anomalyDays: anomalyDays,
      mean: mean.round(),
      stdDev: stdDev.round(),
      isPositiveSpike: anomalyDays.isNotEmpty && dailySteps[anomalyDays.first] > mean,
    );
  }

  // =============================================================
  // 칼로리 추정
  // =============================================================

  double estimateCalories(int steps, {double weightKg = 65, double heightCm = 170}) {
    // MET 기반 추정: 1걸음 ≈ 0.04 kcal (체중 65kg 기준)
    final strideCm = heightCm * 0.415;
    final distanceKm = (steps * strideCm) / 100000;
    // MET 3.5 (중간 속도 걷기) * 체중(kg) * 시간(h)
    final hours = distanceKm / 5.0; // 5km/h 가정
    return (3.5 * weightKg * hours).roundToDouble();
  }

  // =============================================================
  // BMI 추정
  // =============================================================

  double estimateBmi({double weightKg = 65, double heightCm = 170}) {
    final heightM = heightCm / 100;
    return (weightKg / (heightM * heightM) * 10).roundToDouble() / 10;
  }

  String bmiCategory(double bmi) {
    if (bmi < 18.5) return '저체중';
    if (bmi < 23) return '정상';
    if (bmi < 25) return '과체중';
    if (bmi < 30) return '비만';
    return '고도비만';
  }

  // =============================================================
  // 주간 트렌드 분석
  // =============================================================

  TrendAnalysis analyzeTrend(List<int> dailySteps) {
    if (dailySteps.length < 7) {
      return const TrendAnalysis(direction: 'insufficient', changePercent: 0, confidence: 'low');
    }

    // 단순 선형 회귀로 추세 계산
    final n = dailySteps.length;
    final xMean = (n - 1) / 2.0;
    final yMean = dailySteps.reduce((a, b) => a + b) / n;

    double num = 0, den = 0;
    for (int i = 0; i < n; i++) {
      num += (i - xMean) * (dailySteps[i] - yMean);
      den += pow(i - xMean, 2);
    }

    final slope = den != 0 ? num / den : 0;
    final changePercent = yMean > 0 ? (slope * 7 / yMean * 100) : 0;

    String direction;
    if (changePercent > 10) {
      direction = 'strong_up';
    } else if (changePercent > 3) {
      direction = 'up';
    } else if (changePercent > -3) {
      direction = 'stable';
    } else if (changePercent > -10) {
      direction = 'down';
    } else {
      direction = 'strong_down';
    }

    String confidence;
    if (n >= 30) {
      confidence = 'high';
    } else if (n >= 14) {
      confidence = 'medium';
    } else {
      confidence = 'low';
    }

    return TrendAnalysis(
      direction: direction,
      changePercent: changePercent.toDouble(),
      confidence: confidence,
      predictedNextWeek: (yMean + slope * 7).round().clamp(0, 50000).toInt(),
    );
  }

  // =============================================================
  // 최적 목표 계산
  // =============================================================

  int calculateOptimalGoal(List<int> recentSteps, int currentGoal) {
    if (recentSteps.isEmpty) return currentGoal;

    final avg = recentSteps.reduce((a, b) => a + b) ~/ recentSteps.length;
    final trend = analyzeTrend(recentSteps);

    // 상승 추세 → 목표 상향, 하락 추세 → 현실적 하향
    if (trend.direction == 'strong_up') {
      return (avg * 1.15).round();
    } else if (trend.direction == 'up') {
      return (avg * 1.08).round();
    } else if (trend.direction == 'strong_down') {
      return (avg * 0.9).round();
    } else if (trend.direction == 'down') {
      return max(avg, 3000);
    } else {
      return avg;
    }
  }

  // =============================================================
  // 회복 필요 판단
  // =============================================================

  bool needsRestDay(List<int> recentSteps) {
    if (recentSteps.length < 3) return false;

    // 3일 연속 평균의 140% 이상 → 과훈련 가능성
    final avg = recentSteps.reduce((a, b) => a + b) / recentSteps.length;
    final last3 = recentSteps.sublist(recentSteps.length - min(3, recentSteps.length));

    return last3.every((s) => s > avg * 1.4);
  }
}

// ===============================================================
// 분석 결과 모델
// ===============================================================

class AnomalyResult {
  final bool hasAnomaly;
  final List<int> anomalyDays;
  final int mean;
  final int stdDev;
  final bool isPositiveSpike;

  const AnomalyResult({
    required this.hasAnomaly,
    required this.anomalyDays,
    this.mean = 0,
    this.stdDev = 0,
    this.isPositiveSpike = false,
  });
}

class TrendAnalysis {
  final String direction; // strong_up, up, stable, down, strong_down, insufficient
  final double changePercent;
  final String confidence; // high, medium, low
  final int predictedNextWeek;

  const TrendAnalysis({
    required this.direction,
    required this.changePercent,
    required this.confidence,
    this.predictedNextWeek = 0,
  });

  String get directionLabel => switch (direction) {
    'strong_up' => '📈 급상승',
    'up' => '📈 상승',
    'stable' => '➡️ 안정',
    'down' => '📉 하락',
    'strong_down' => '📉 급하락',
    _ => '데이터 부족',
  };

  String get directionEmoji => switch (direction) {
    'strong_up' => '🚀', 'up' => '📈', 'stable' => '✨', 'down' => '📉', 'strong_down' => '⚠️', _ => '📊',
  };
}
