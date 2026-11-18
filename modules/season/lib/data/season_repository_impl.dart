part of 'data.dart';

class SeasonRepositoryImpl implements SeasonRepository {
  final SeasonRemoteDataSource remote;
  SeasonRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, SeasonDetail>> getSeasonDetail(
    int tvId,
    int seasonNumber,
  ) => guard(
    () async => (await remote.seasonDetail(tvId, seasonNumber)).toEntity(),
  );
}
