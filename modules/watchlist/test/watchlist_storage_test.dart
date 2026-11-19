import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:watchlist/data/data.dart';
import 'package:watchlist/domain/domain.dart';

import 'helpers/items.dart';

MediaItem item(int id, MediaType type) =>
    MediaItem(id: id, type: type, title: '$type $id', voteAverage: 0);

String tempDbPath() => '${Directory.systemTemp.createTempSync().path}/w.db';

DatabaseHelper helperAt(String path) =>
    DatabaseHelper(factory: databaseFactoryFfi, path: path);

void main() {
  setUpAll(sqfliteFfiInit);

  test('watchlist survives closing and reopening the database', () async {
    final path = tempDbPath();
    final a = helperAt(path);
    await a.insert(WatchlistTable.fromEntity(darkItem));
    await a.close();

    final b = helperAt(path);
    expect(await b.contains(1, MediaType.tv), isTrue);
    expect((await b.all()).single.toEntity(), darkItem);
    await b.close();
  });

  test(
    'a movie and a TV series with the same id are separate entries',
    () async {
      final db = helperAt(tempDbPath());
      await db.insert(WatchlistTable.fromEntity(darkItem));
      await db.insert(WatchlistTable.fromEntity(inceptionItem));
      expect((await db.all()).length, 2);

      await db.remove(1, MediaType.movie);
      expect(await db.contains(1, MediaType.movie), isFalse);
      expect(await db.contains(1, MediaType.tv), isTrue);
      await db.close();
    },
  );

  test('adding the same item twice keeps one row', () async {
    final db = helperAt(tempDbPath());
    await db.insert(WatchlistTable.fromEntity(darkItem));
    await db.insert(WatchlistTable.fromEntity(darkItem));
    expect((await db.all()).length, 1);
    await db.close();
  });

  test('removing a missing item is a no-op', () async {
    final db = helperAt(tempDbPath());
    await db.remove(42, MediaType.tv);
    expect(await db.all(), isEmpty);
    await db.close();
  });

  test('all() returns newest first', () async {
    final db = helperAt(tempDbPath());
    await db.insert(WatchlistTable.fromEntity(item(1, MediaType.tv)));
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await db.insert(WatchlistTable.fromEntity(item(2, MediaType.movie)));
    expect((await db.all()).map((e) => e.id), [2, 1]);
    await db.close();
  });

  test('upgrading a v1 (TV-only) database keeps its rows as TV series', () async {
    final path = tempDbPath();
    final v1 = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => db.execute(
          'CREATE TABLE watchlist (id INTEGER PRIMARY KEY, name TEXT NOT NULL, overview TEXT, posterPath TEXT, voteAverage REAL NOT NULL, addedAt INTEGER NOT NULL)',
        ),
      ),
    );
    await v1.insert('watchlist', {
      'id': 1,
      'name': 'Dark',
      'overview': 'x',
      'posterPath': '/p.jpg',
      'voteAverage': 8.4,
      'addedAt': 1,
    });
    await v1.close();

    final db = helperAt(path);
    expect((await db.all()).single.toEntity(), darkItem);
    await db.insert(WatchlistTable.fromEntity(inceptionItem));
    expect((await db.all()).length, 2);
    await db.close();
  });

  test('repository save/remove return messages and update status', () async {
    final db = helperAt(tempDbPath());
    final repo = WatchlistRepositoryImpl(db);
    expect(
      await repo.saveWatchlist(inceptionItem),
      const Right<Failure, String>('Added to Watchlist'),
    );
    expect(
      await repo.isAddedToWatchlist(1, MediaType.movie),
      const Right<Failure, bool>(true),
    );
    expect(
      await repo.isAddedToWatchlist(1, MediaType.tv),
      const Right<Failure, bool>(false),
    );
    expect((await repo.getWatchlist()).getOrElse((_) => []), [inceptionItem]);
    expect(
      await repo.removeWatchlist(1, MediaType.movie),
      const Right<Failure, String>('Removed from Watchlist'),
    );
    expect(
      await repo.isAddedToWatchlist(1, MediaType.movie),
      const Right<Failure, bool>(false),
    );
    await db.close();
  });

  test('a database that cannot be opened becomes a DatabaseFailure', () async {
    final repo = WatchlistRepositoryImpl(
      helperAt(Directory.systemTemp.createTempSync().path),
    );
    expect(
      (await repo.getWatchlist()).getLeft().toNullable(),
      isA<DatabaseFailure>(),
    );
  });
}
