import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/health_repository.dart';

class StepSyncService {
  StepSyncService(this._repository);

  final HealthRepository _repository;

  final _supabase = Supabase.instance.client;

  /// ----------------------------------------------------------
  /// Health Connect → Supabase 동기화
  /// ----------------------------------------------------------
  Future<bool> syncTodaySteps(String userId) async {
    try {
      //--------------------------------------------------------
      // 권한
      //--------------------------------------------------------

      final granted =
          await _repository.requestAuthorization();

      if (!granted) {
        return false;
      }

      //--------------------------------------------------------
      // 데이터 읽기
      //--------------------------------------------------------

      final steps =
          await _repository.getTodaySteps();

      final distance =
          await _repository.estimateDistanceKm();

      final calories =
          await _repository.estimateCalories();

      final today =
          DateTime.now().toIso8601String().substring(0, 10);

      //--------------------------------------------------------
      // 이미 저장되어 있는지
      //--------------------------------------------------------

      final exists = await _supabase
          .from("steps")
          .select("id")
          .eq("user_id", userId)
          .eq("date", today)
          .maybeSingle();

      //--------------------------------------------------------
      // UPDATE
      //--------------------------------------------------------

      if (exists != null) {
        await _supabase
            .from("steps")
            .update({
              "steps": steps,
              "distance": distance,
              "calories": calories,
              "updated_at": DateTime.now().toIso8601String(),
            })
            .eq("id", exists["id"]);

        return true;
      }

      //--------------------------------------------------------
      // INSERT
      //--------------------------------------------------------

      await _supabase
          .from("steps")
          .insert({
            "user_id": userId,
            "date": today,
            "steps": steps,
            "distance": distance,
            "calories": calories,
            "created_at": DateTime.now().toIso8601String(),
          });

      return true;
    } catch (e) {
      print("StepSyncService : $e");
      return false;
    }
  }
}
