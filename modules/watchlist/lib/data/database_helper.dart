part of 'data.dart';

class DatabaseHelper {
  static const _table = 'watchlist';

  final DatabaseFactory? _factory;
  final String? _path;
  Future<Database>? _db;

  DatabaseHelper({DatabaseFactory? factory, String? path})
    : _factory = factory,
      _path = path;

  Future<Database> get database => _db ??= _open();

  Future<Database> _open() async {
    final factory = _factory ?? databaseFactory;
    final path = _path ?? '${await factory.getDatabasesPath()}/cineblix.db';
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, _) => _createTable(db),
        onUpgrade: (db, oldVersion, _) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE $_table RENAME TO ${_table}_v1');
            await _createTable(db);
            await db.execute(
              '''
              INSERT INTO $_table (id, type, name, overview, posterPath, voteAverage, addedAt)
              SELECT id, 'tv', name, overview, posterPath, voteAverage, addedAt FROM ${_table}_v1''',
            );
            await db.execute('DROP TABLE ${_table}_v1');
          }
        },
      ),
    );
  }

  static Future<void> _createTable(Database db) => db.execute('''
    CREATE TABLE $_table (
      id INTEGER NOT NULL,
      type TEXT NOT NULL,
      name TEXT NOT NULL,
      overview TEXT,
      posterPath TEXT,
      voteAverage REAL NOT NULL,
      addedAt INTEGER NOT NULL,
      PRIMARY KEY (id, type)
    )''');

  Future<void> insert(WatchlistTable tv) async => (await database).insert(
    _table,
    tv.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  Future<void> remove(int id, MediaType type) async => (await database).delete(
    _table,
    where: 'id = ? AND type = ?',
    whereArgs: [id, type.name],
  );

  Future<bool> contains(int id, MediaType type) async =>
      (await (await database).query(
        _table,
        columns: ['id'],
        where: 'id = ? AND type = ?',
        whereArgs: [id, type.name],
      )).isNotEmpty;

  Future<List<WatchlistTable>> all() async => (await (await database).query(
    _table,
    orderBy: 'addedAt DESC',
  )).map(WatchlistTable.fromMap).toList();

  Future<void> close() async {
    final db = _db;
    _db = null;
    if (db != null) await (await db).close();
  }
}
