part of '../use_cases.dart';

class RemoveWatchlist {
  final WatchlistRepository repository;
  RemoveWatchlist(this.repository);

  Future<Either<Failure, String>> call(int id, MediaType type) =>
      repository.removeWatchlist(id, type);
}
