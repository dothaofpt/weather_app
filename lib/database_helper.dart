import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'weather.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('weather.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE weather (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dateTime TEXT NOT NULL,
      temperature REAL NOT NULL,
      humidity INTEGER NOT NULL,
      description TEXT NOT NULL,
      icon TEXT NOT NULL
    )
    ''');
  }

  Future<void> insertWeather(Weather weather) async {
    final db = await database;
    await db.insert('weather', weather.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Weather>> getWeather() async {
    final db = await database;
    final maps = await db.query('weather', orderBy: 'dateTime');
    return List.generate(maps.length, (i) => Weather.fromMap(maps[i]));
  }

  Future<void> clearWeather() async {
    final db = await database;
    await db.delete('weather');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}