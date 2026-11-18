part of '../domain.dart';

abstract class TvDetailRepository {
  Future<Either<Failure, TvDetail>> getTvDetail(int id);
  Future<Either<Failure, List<Tv>>> getTvRecommendations(int id);
}
