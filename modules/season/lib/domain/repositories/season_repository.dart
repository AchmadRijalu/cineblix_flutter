part of '../domain.dart';

abstract class SeasonRepository {
  Future<Either<Failure, SeasonDetail>> getSeasonDetail(
    int tvId,
    int seasonNumber,
  );
}
