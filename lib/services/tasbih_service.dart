import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tasbih_record.dart';

class TasbihService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'tasbih.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasbih_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            count INTEGER NOT NULL,
            type TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> saveRecord(TasbihRecord record) async {
    final db = await database;
    await db.insert(
      'tasbih_records',
      record.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<TasbihRecord>> getRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasbih_records');

    return List.generate(maps.length, (i) {
      return TasbihRecord(
        date: DateTime.parse(maps[i]['date']),
        count: maps[i]['count'],
        type: maps[i]['type'],
      );
    });
  }

  static Future<TasbihRecord?> getTodayRecord() async {
    final db = await database;
    final now = DateTime.now();
    final dateStr = now.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> result = await db.query(
      'tasbih_records',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
    );

    if (result.isEmpty) {
      return TasbihRecord(
        date: now,
        count: 0,
        type: 'Subhanallah',
      );
    }

    return TasbihRecord(
      date: DateTime.parse(result.first['date']),
      count: result.first['count'],
      type: result.first['type'],
    );
  }

  static Future<void> updateTodayCount(int count) async {
    final db = await database;
    final now = DateTime.now();
    final dateStr = now.toIso8601String();

    final record = TasbihRecord(
      date: now,
      count: count,
      type: 'Subhanallah',
    );

    await db.delete(
      'tasbih_records',
      where: 'date LIKE ?',
      whereArgs: ['${dateStr.split('T')[0]}%'],
    );

    await db.insert(
      'tasbih_records',
      record.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
