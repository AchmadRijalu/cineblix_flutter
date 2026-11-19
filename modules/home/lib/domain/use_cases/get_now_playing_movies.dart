part of '../domain.dart';

class GetNowPlayingMovies {
  final HomeRepository repository;
  GetNowPlayingMovies(this.repository);

  Future<Either<Failure, List<Movie>>> call() =>
      repository.getNowPlayingMovies();
}
