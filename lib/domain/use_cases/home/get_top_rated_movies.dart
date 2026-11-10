part of '../use_cases.dart';

class GetTopRatedMovies {
  final HomeRepository repository;
  GetTopRatedMovies(this.repository);

  Future<Either<Failure, List<Movie>>> call() => repository.getTopRatedMovies();
}
