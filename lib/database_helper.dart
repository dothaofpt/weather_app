import 'dart:io' show Platform;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'weather.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Khởi tạo databaseFactory cho ffi nếu chạy trên Windows/Linux/macOS
  static void initDatabaseFactory() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        sqfliteFfiInit(); // Khởi tạo SQLite FFI trước khi thiết lập databaseFactory
        databaseFactory = databaseFactoryFfi;
        print('Initialized databaseFactory for ffi');
      } catch (e) {
        print('Error initializing databaseFactory: $e');
      }
    } else {
      print('Running on non-desktop platform, no ffi initialization needed');
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('weather.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('Database path: $path');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
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
    await db.insert(
      'weather',
      weather.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
    await db.close();
  }
}
