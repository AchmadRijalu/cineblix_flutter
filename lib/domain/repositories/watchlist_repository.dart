part of 'repositories.dart';

abstract class WatchlistRepository {
  Future<Either<Failure, String>> saveWatchlist(MediaItem item);
  Future<Either<Failure, String>> removeWatchlist(int id, MediaType type);
  Future<Either<Failure, bool>> isAddedToWatchlist(int id, MediaType type);
  Future<Either<Failure, List<MediaItem>>> getWatchlist();
}
