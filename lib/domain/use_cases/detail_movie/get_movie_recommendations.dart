part of '../use_cases.dart';

class GetMovieRecommendations {
  final DetailMovieRepository repository;
  GetMovieRecommendations(this.repository);

  Future<Either<Failure, List<Movie>>> call(int id) =>
      repository.getMovieRecommendations(id);
}
