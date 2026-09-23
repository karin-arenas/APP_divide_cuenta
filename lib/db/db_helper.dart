import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper central de SQLite. Toda la data de la app (personas, eventos,
/// ítems, repartos) vive 100% local en este archivo .db en el dispositivo.
class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static const _dbName = 'divide_cuenta.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE people (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        tip_percent REAL NOT NULL DEFAULT 10,
        tip_enabled INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE event_participants (
        event_id TEXT NOT NULL,
        person_id TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (event_id, person_id),
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 1,
        unit_price INTEGER NOT NULL DEFAULT 0,
        total_price INTEGER NOT NULL DEFAULT 0,
        is_extra INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE item_shares (
        item_id TEXT NOT NULL,
        person_id TEXT NOT NULL,
        PRIMARY KEY (item_id, person_id),
        FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
        FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tip_overrides (
        event_id TEXT NOT NULL,
        person_id TEXT NOT NULL,
        type TEXT NOT NULL,
        value REAL NOT NULL DEFAULT 0,
        PRIMARY KEY (event_id, person_id),
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('tip_overrides');
    await db.delete('item_shares');
    await db.delete('items');
    await db.delete('event_participants');
    await db.delete('events');
    await db.delete('people');
  }
}
