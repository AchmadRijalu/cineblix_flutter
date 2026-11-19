part of '../domain.dart';

class GetWatchlistStatus {
  final WatchlistRepository repository;
  GetWatchlistStatus(this.repository);

  Future<Either<Failure, bool>> call(int id, MediaType type) =>
      repository.isAddedToWatchlist(id, type);
}
