import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:rewire/core/services/app_database.dart';
import 'package:rewire/models/dopamine_item_model.dart';
import 'package:rewire/models/star_model.dart';
import 'package:rewire/models/trigger_log_model.dart';
import 'package:rewire/models/user_model.dart';

class SqliteAppDatabase implements AppDatabase {
  Database? _db;

  Database get db {
    final database = _db;
    if (database == null) {
      throw StateError('Baza de date nu a fost inițializată.');
    }
    return database;
  }

  @override
  Future<void> init() async {
    final path = p.join(await getDatabasesPath(), 'rewire.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, _) async {
        await database.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            created_at INTEGER NOT NULL,
            incognito_mode INTEGER NOT NULL DEFAULT 0,
            notifications_enabled INTEGER NOT NULL DEFAULT 1,
            check_in_hour INTEGER,
            display_name TEXT,
            last_synced_at INTEGER
          )
        ''');
        await database.execute('''
          CREATE TABLE trigger_logs (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            trigger_label TEXT,
            intensity INTEGER,
            notes TEXT,
            outcome TEXT NOT NULL,
            follow_up_done INTEGER NOT NULL DEFAULT 0,
            chosen_alternative TEXT,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await database.execute('''
          CREATE TABLE dopamine_items (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT NOT NULL,
            duration_minutes INTEGER NOT NULL,
            is_custom INTEGER NOT NULL DEFAULT 0,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await database.execute('''
          CREATE TABLE stars (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            source_log_id TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final rows = await db.query('users', limit: 1);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertTriggerLog(TriggerLogModel log) async {
    await db.insert(
      'trigger_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<TriggerLogModel>> listTriggerLogs(String userId) async {
    final rows = await db.query(
      'trigger_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(TriggerLogModel.fromMap).toList();
  }

  @override
  Future<TriggerLogModel?> getTriggerLog(String id) async {
    final rows = await db.query(
      'trigger_logs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TriggerLogModel.fromMap(rows.first);
  }

  @override
  Future<List<TriggerLogModel>> unsyncedTriggerLogs(String userId) async {
    final rows = await db.query(
      'trigger_logs',
      where: 'user_id = ? AND synced = 0',
      whereArgs: [userId],
    );
    return rows.map(TriggerLogModel.fromMap).toList();
  }

  @override
  Future<void> upsertDopamineItem(DopamineItemModel item) async {
    await db.insert(
      'dopamine_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<DopamineItemModel>> listDopamineItems() async {
    final rows = await db.query('dopamine_items', orderBy: 'duration_minutes ASC');
    return rows.map(DopamineItemModel.fromMap).toList();
  }

  @override
  Future<List<DopamineItemModel>> unsyncedCustomItems() async {
    final rows = await db.query(
      'dopamine_items',
      where: 'is_custom = 1 AND synced = 0',
    );
    return rows.map(DopamineItemModel.fromMap).toList();
  }

  @override
  Future<void> addStar(StarModel star) async {
    await db.insert(
      'stars',
      star.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<List<StarModel>> listStars(String userId) async {
    final rows = await db.query(
      'stars',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
    return rows.map(StarModel.fromMap).toList();
  }

  @override
  Future<int> starCount(String userId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM stars WHERE user_id = ?',
      [userId],
    );
    return (result.first['c'] as int?) ?? 0;
  }

  @override
  Future<void> markTriggerSynced(String id) async {
    await db.update('trigger_logs', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> markDopamineSynced(String id) async {
    await db.update(
      'dopamine_items',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
