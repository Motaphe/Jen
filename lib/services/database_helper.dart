import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';
import '../models/mood_entry.dart';
import '../models/lockdown_entry.dart';
import '../models/water_entry.dart';
import '../models/breathing_entry.dart';

/// Singleton SQLite database manager for all app data persistence.
/// Handles schema creation, migrations, and CRUD operations for all models.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Lazy initialization of database connection.
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
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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

    // Lockdown entries table
    await db.execute('''
      CREATE TABLE lockdown_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        completed INTEGER NOT NULL,
        task_name TEXT
      )
    ''');

    // Water reminders table
    await db.execute('''
      CREATE TABLE water_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        confirmed INTEGER NOT NULL
      )
    ''');

    // Breathing exercise sessions table
    await db.execute('''
      CREATE TABLE breathing_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        completed INTEGER NOT NULL
      )
    ''');
  }

  /// Handles database version upgrades for backward compatibility.
  /// v1->v2: Added lockdown_entries table
  /// v2->v3: Added water_entries and breathing_entries tables
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE lockdown_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_time TEXT NOT NULL,
          duration_minutes INTEGER NOT NULL,
          completed INTEGER NOT NULL,
          task_name TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE water_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp TEXT NOT NULL,
          confirmed INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE breathing_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_time TEXT NOT NULL,
          duration_seconds INTEGER NOT NULL,
          completed INTEGER NOT NULL
        )
      ''');
    }
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

  /// Retrieves mood entries within date range for chart visualization.
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

  Future<List<Map<String, dynamic>>> getFavoriteAffirmations() async {
    final db = await database;
    final result = await db.query(
      'favorite_affirmations',
      orderBy: 'saved_at DESC',
    );
    return result;
  }

  Future<int> deleteFavoriteAffirmation(int id) async {
    final db = await database;
    return await db.delete(
      'favorite_affirmations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isAffirmationLiked(String text) async {
    final db = await database;
    final result = await db.query(
      'favorite_affirmations',
      where: 'text = ?',
      whereArgs: [text],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> unlikeAffirmation(String text) async {
    final db = await database;
    return await db.delete(
      'favorite_affirmations',
      where: 'text = ?',
      whereArgs: [text],
    );
  }

  // Lockdown entries operations
  Future<int> createLockdownEntry(LockdownEntry entry) async {
    final db = await database;
    return await db.insert('lockdown_entries', entry.toMap());
  }

  Future<List<LockdownEntry>> getAllLockdownEntries() async {
    final db = await database;
    final result = await db.query(
      'lockdown_entries',
      orderBy: 'start_time DESC',
    );
    return result.map((map) => LockdownEntry.fromMap(map)).toList();
  }

  /// Computes aggregate statistics for lockdown session history display.
  Future<Map<String, dynamic>> getLockdownStats() async {
    final entries = await getAllLockdownEntries();

    int totalSessions = entries.length;
    int completedSessions = entries.where((e) => e.completed).length;
    int totalFocusMinutes = entries
        .where((e) => e.completed)
        .fold(0, (sum, e) => sum + e.durationMinutes);
    double completionRate =
        totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0;

    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'totalFocusMinutes': totalFocusMinutes,
      'completionRate': completionRate,
    };
  }

  // Water entries operations
  Future<int> createWaterEntry(WaterEntry entry) async {
    final db = await database;
    return await db.insert('water_entries', entry.toMap());
  }

  Future<List<WaterEntry>> getAllWaterEntries() async {
    final db = await database;
    final result = await db.query(
      'water_entries',
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => WaterEntry.fromMap(map)).toList();
  }

  /// Retrieves water intake entries for specific date (daily goal tracking).
  Future<List<WaterEntry>> getWaterEntriesForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await db.query(
      'water_entries',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => WaterEntry.fromMap(map)).toList();
  }

  // Breathing entries operations
  Future<int> createBreathingEntry(BreathingEntry entry) async {
    final db = await database;
    return await db.insert('breathing_entries', entry.toMap());
  }

  Future<List<BreathingEntry>> getAllBreathingEntries() async {
    final db = await database;
    final result = await db.query(
      'breathing_entries',
      orderBy: 'start_time DESC',
    );
    return result.map((map) => BreathingEntry.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
