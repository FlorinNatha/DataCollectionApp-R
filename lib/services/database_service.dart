import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/sample.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bell_pepper_collector.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE samples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filename TEXT,
        disease_label TEXT,
        stage TEXT,
        n REAL,
        p REAL,
        k REAL,
        ph REAL,
        ec REAL,
        moisture REAL,
        temp REAL,
        location TEXT,
        date TEXT,
        notes TEXT
      )
    ''');
  }

  Future<int> insertSample(Sample sample) async {
    Database db = await database;
    return await db.insert('samples', sample.toMap());
  }

  Future<List<Sample>> getSamples() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('samples', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return Sample.fromMap(maps[i]);
    });
  }

  Future<int> deleteSample(int id) async {
    Database db = await database;
    return await db.delete('samples', where: 'id = ?', whereArgs: [id]);
  }
}
