part of '../use_cases.dart';

class GetWatchlist {
  final WatchlistRepository repository;
  GetWatchlist(this.repository);

  Future<Either<Failure, List<MediaItem>>> call() => repository.getWatchlist();
}
