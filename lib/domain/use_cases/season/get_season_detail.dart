part of '../use_cases.dart';

class GetSeasonDetail {
  final SeasonRepository repository;
  GetSeasonDetail(this.repository);

  Future<Either<Failure, SeasonDetail>> call(int tvId, int seasonNumber) =>
      repository.getSeasonDetail(tvId, seasonNumber);
}
