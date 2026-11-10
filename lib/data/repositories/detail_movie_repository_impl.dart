part of 'repositories.dart';

class DetailMovieRepositoryImpl implements DetailMovieRepository {
  final DetailMovieRemoteDataSource remote;
  DetailMovieRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int id) =>
      guard(() async => (await remote.detail(id)).toEntity());

  @override
  Future<Either<Failure, List<Movie>>> getMovieRecommendations(int id) => guard(
    () async =>
        (await remote.recommendations(id)).map((e) => e.toEntity()).toList(),
  );
}
