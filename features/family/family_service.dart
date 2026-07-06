import 'package:supabase_flutter/supabase_flutter.dart';

class FamilyService {
  final supabase = Supabase.instance.client;

  /// 가족 생성
  Future<String> createFamily(String name, String userId) async {
    final res = await supabase.from('family_groups').insert({
      'name': name,
      'created_by': userId,
    }).select();

    return res.first['id'];
  }

  /// 가족 가입
  Future<void> joinFamily(String familyId, String userId) async {
    await supabase.from('family_members').insert({
      'family_id': familyId,
      'user_id': userId,
      'role': 'member',
    });
  }

  /// 가족 걸음 합산
  Future<int> getFamilySteps(String familyId) async {
    final data = await supabase
        .from('family_ranking')
        .select()
        .eq('family_id', familyId);

    return data.fold<int>(
      0,
      (sum, e) => sum + (e['steps'] ?? 0),
    );
  }

  /// 가족 순위
  Future<List<Map<String, dynamic>>> getFamilyRanking(
      String familyId) async {
    final data = await supabase
        .from('family_ranking')
        .select()
        .eq('family_id', familyId);

    data.sort((a, b) => b['steps'].compareTo(a['steps']));
    return data;
  }
}
