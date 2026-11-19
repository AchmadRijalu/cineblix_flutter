part of '../domain.dart';

class SaveWatchlist {
  final WatchlistRepository repository;
  SaveWatchlist(this.repository);

  Future<Either<Failure, String>> call(MediaItem item) =>
      repository.saveWatchlist(item);
}
