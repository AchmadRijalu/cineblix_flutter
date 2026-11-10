part of '../use_cases.dart';

class GetMovieDetail {
  final DetailMovieRepository repository;
  GetMovieDetail(this.repository);

  Future<Either<Failure, MovieDetail>> call(int id) =>
      repository.getMovieDetail(id);
}
