part of '../use_cases.dart';

class GetTvRecommendations {
  final TvDetailRepository repository;
  GetTvRecommendations(this.repository);

  Future<Either<Failure, List<Tv>>> call(int id) =>
      repository.getTvRecommendations(id);
}
