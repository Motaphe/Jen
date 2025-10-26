import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';
import '../models/mood_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jen.db');
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
    // Journal entries table
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // Mood entries table
    await db.execute('''
      CREATE TABLE mood_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mood INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');

    // Affirmations table
    await db.execute('''
      CREATE TABLE favorite_affirmations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        saved_at TEXT NOT NULL
      )
    ''');
  }

  // Journal CRUD operations
  Future<int> createJournalEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert('journal_entries', entry.toMap());
  }

  Future<List<JournalEntry>> getAllJournalEntries() async {
    final db = await database;
    final result = await db.query(
      'journal_entries',
      orderBy: 'date DESC',
    );
    return result.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<int> updateJournalEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteJournalEntry(int id) async {
    final db = await database;
    return await db.delete(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mood CRUD operations
  Future<int> createMoodEntry(MoodEntry entry) async {
    final db = await database;
    return await db.insert('mood_entries', entry.toMap());
  }

  Future<List<MoodEntry>> getAllMoodEntries() async {
    final db = await database;
    final result = await db.query(
      'mood_entries',
      orderBy: 'date DESC',
    );
    return result.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<List<MoodEntry>> getMoodEntriesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'mood_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );
    return result.map((map) => MoodEntry.fromMap(map)).toList();
  }

  // Affirmations operations
  Future<int> saveFavoriteAffirmation(String text) async {
    final db = await database;
    return await db.insert('favorite_affirmations', {
      'text': text,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<String>> getFavoriteAffirmations() async {
    final db = await database;
    final result = await db.query(
      'favorite_affirmations',
      orderBy: 'saved_at DESC',
    );
    return result.map((map) => map['text'] as String).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
