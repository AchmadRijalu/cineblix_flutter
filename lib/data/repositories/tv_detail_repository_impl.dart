part of 'repositories.dart';

class TvDetailRepositoryImpl implements TvDetailRepository {
  final TvDetailRemoteDataSource remote;
  TvDetailRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, TvDetail>> getTvDetail(int id) =>
      guard(() async => (await remote.detail(id)).toEntity());

  @override
  Future<Either<Failure, List<Tv>>> getTvRecommendations(int id) => guard(
    () async =>
        (await remote.recommendations(id)).map((e) => e.toEntity()).toList(),
  );
}
