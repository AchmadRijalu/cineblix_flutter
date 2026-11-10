part of '../use_cases.dart';

class GetPopularMovies {
  final HomeRepository repository;
  GetPopularMovies(this.repository);

  Future<Either<Failure, List<Movie>>> call() => repository.getPopularMovies();
}
