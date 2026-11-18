part of 'data.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final DatabaseHelper db;
  WatchlistRepositoryImpl(this.db);

  @override
  Future<Either<Failure, String>> saveWatchlist(MediaItem item) => guard(
    () async => db
        .insert(WatchlistTable.fromEntity(item))
        .then((_) => 'Added to Watchlist'),
  );

  @override
  Future<Either<Failure, String>> removeWatchlist(int id, MediaType type) =>
      guard(
        () async => db.remove(id, type).then((_) => 'Removed from Watchlist'),
      );

  @override
  Future<Either<Failure, bool>> isAddedToWatchlist(int id, MediaType type) =>
      guard(() => db.contains(id, type));

  @override
  Future<Either<Failure, List<MediaItem>>> getWatchlist() =>
      guard(() async => (await db.all()).map((e) => e.toEntity()).toList());
}
