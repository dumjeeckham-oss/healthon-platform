import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../domain/models/health_models.dart';
import '../health_mapper.dart';

/// ===============================================================
/// HealthON — Local Health Cache (SQLite)
///
/// Android / iOS:
///   오프라인 상태에서 Health 데이터를 SQLite에 임시 저장
///   온라인 되면 Supabase로 자동 업로드
///
/// Web:
///   SQLite를 사용하지 않음.
///   로컬 Health Cache 기능을 비활성화하고 안전하게 return.
/// ===============================================================

class LocalHealthCache {
  static LocalHealthCache? _instance;
  Database? _db;

  static const String _dbName = 'healthon_local_health.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'pending_health_daily';

  factory LocalHealthCache() {
    _instance ??= LocalHealthCache._();
    return _instance!;
  }

  LocalHealthCache._();

  /// =============================================================
  /// Database
  /// =============================================================

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'LocalHealthCache SQLite is not supported on Web.',
      );
    }

    if (_db != null) {
      return _db!;
    }

    _db = await openDatabase(
      p.join(
        await getDatabasesPath(),
        _dbName,
      ),
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  /// =============================================================
  /// Save — 오프라인 저장
  /// =============================================================

  Future<void> savePending(HealthDaily data) async {
    if (kIsWeb) {
      debugPrint(
        '💾 LocalHealthCache: Web — SQLite save skipped',
      );
      return;
    }

    final db = await database;
    final key = '${data.userId}_${data.dateKey}';

    await db.insert(
      _tableName,
      {
        'id': key,
        'payload': jsonEncode(
          data.toSupabase(),
        ),
        'attempts': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// =============================================================
  /// Get All — 미전송 데이터 모두 조회
  /// =============================================================

  Future<List<HealthDaily>> getPending() async {
    if (kIsWeb) {
      debugPrint(
        '💾 LocalHealthCache: Web — no pending SQLite data',
      );
      return <HealthDaily>[];
    }

    final db = await database;

    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      orderBy: 'created_at ASC',
    );

    return rows.map((row) {
      final Map<String, dynamic> payload =
          jsonDecode(row['payload'] as String);

      return HealthDailySupabaseMapper.fromSupabase(
        payload,
      );
    }).toList();
  }

  /// =============================================================
  /// Count — 미전송 개수
  /// =============================================================

  Future<int> pendingCount() async {
    if (kIsWeb) {
      return 0;
    }

    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM $_tableName',
    );

    return (result.first['cnt'] ?? 0) as int;
  }

  /// =============================================================
  /// Remove — 전송 완료 or 최대 재시도 초과
  /// =============================================================

  Future<void> removePending(
    String userId,
    DateTime date,
  ) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;

    final key =
        '${userId}_${date.toIso8601String().substring(0, 10)}';

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [key],
    );
  }

  /// =============================================================
  /// Increment Attempts — 재시도 횟수 증가
  /// =============================================================

  Future<void> incrementAttempts(
    String userId,
    DateTime date,
  ) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;

    final key =
        '${userId}_${date.toIso8601String().substring(0, 10)}';

    await db.rawUpdate(
      'UPDATE $_tableName '
      'SET attempts = attempts + 1 '
      'WHERE id = ?',
      [key],
    );
  }

  /// =============================================================
  /// Clear All
  /// =============================================================

  Future<void> clearAll() async {
    if (kIsWeb) {
      return;
    }

    final db = await database;

    await db.delete(_tableName);
  }

  /// =============================================================
  /// Get max attempts
  /// =============================================================

  Future<int> getAttempts(
    String userId,
    DateTime date,
  ) async {
    if (kIsWeb) {
      return 0;
    }

    final db = await database;

    final key =
        '${userId}_${date.toIso8601String().substring(0, 10)}';

    final rows = await db.query(
      _tableName,
      columns: ['attempts'],
      where: 'id = ?',
      whereArgs: [key],
    );

    if (rows.isEmpty) {
      return 0;
    }

    return (rows.first['attempts'] ?? 0) as int;
  }
}
