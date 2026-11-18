part of '../domain.dart';

abstract class DetailMovieRepository {
  Future<Either<Failure, MovieDetail>> getMovieDetail(int id);
  Future<Either<Failure, List<Movie>>> getMovieRecommendations(int id);
}
