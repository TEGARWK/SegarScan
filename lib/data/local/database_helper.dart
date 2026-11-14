import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/scan_history_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('segarscan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        fruit_name TEXT NOT NULL,
        quality TEXT NOT NULL,
        confidence REAL NOT NULL,
        prob_good REAL NOT NULL,
        prob_fair REAL NOT NULL,
        prob_bad REAL NOT NULL,
        inference_ms INTEGER NOT NULL,
        source TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertScan(ScanHistoryItem item) async {
    final db = await instance.database;
    return await db.insert('scan_history', item.toMap());
  }

  Future<List<ScanHistoryItem>> getAllHistory({
    String? quality,
    String? fruit,
  }) async {
    final db = await instance.database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (quality != null && fruit != null) {
      whereClause = 'quality = ? AND fruit_name = ?';
      whereArgs = [quality, fruit];
    } else if (quality != null) {
      whereClause = 'quality = ?';
      whereArgs = [quality];
    } else if (fruit != null) {
      whereClause = 'fruit_name = ?';
      whereArgs = [fruit];
    }

    final maps = await db.query(
      'scan_history',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return maps.map((e) => ScanHistoryItem.fromMap(e)).toList();
  }

  Future<List<ScanHistoryItem>> getRecentScans({int limit = 5}) async {
    final db = await instance.database;
    final maps = await db.query(
      'scan_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((e) => ScanHistoryItem.fromMap(e)).toList();
  }

  Future<int> deleteScan(int id) async {
    final db = await instance.database;
    return await db.delete(
      'scan_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAll() async {
    final db = await instance.database;
    return await db.delete('scan_history');
  }

  Future<Map<String, int>> getQualityCounts() async {
    final db = await instance.database;
    final results = await db.rawQuery('''
      SELECT quality, COUNT(*) as count 
      FROM scan_history 
      GROUP BY quality
    ''');

    final counts = {'bagus': 0, 'cukup': 0, 'busuk': 0};
    for (final row in results) {
      final q = (row['quality'] as String?)?.toLowerCase();
      final c = (row['count'] as num?)?.toInt() ?? 0;
      if (q != null && counts.containsKey(q)) {
        counts[q] = c;
      }
    }
    return counts;
  }

  Future<Map<String, int>> getFruitTypeCounts() async {
    final db = await instance.database;
    final results = await db.rawQuery('''
      SELECT fruit_name, COUNT(*) as count 
      FROM scan_history 
      GROUP BY fruit_name
    ''');

    final Map<String, int> counts = {};
    for (final row in results) {
      final f = row['fruit_name'] as String? ?? 'unknown';
      final c = (row['count'] as num?)?.toInt() ?? 0;
      counts[f] = c;
    }
    return counts;
  }

  Future<int> getTotalScans() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM scan_history'),
    );
    return count ?? 0;
  }
}
