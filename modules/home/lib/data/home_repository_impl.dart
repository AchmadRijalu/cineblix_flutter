part of 'data.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;
  HomeRepositoryImpl(this.remote);

  Future<Either<Failure, List<Movie>>> _movies(
    Future<List<MovieModel>> Function() fetch,
  ) => guard(() async => (await fetch()).map((e) => e.toEntity()).toList());

  Future<Either<Failure, List<Tv>>> _tvs(
    Future<List<TvModel>> Function() fetch,
  ) => guard(() async => (await fetch()).map((e) => e.toEntity()).toList());

  @override
  Future<Either<Failure, List<Movie>>> getNowPlayingMovies() =>
      _movies(remote.nowPlaying);
  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies() =>
      _movies(remote.popular);
  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies() =>
      _movies(remote.topRated);
  @override
  Future<Either<Failure, List<Tv>>> getOnTheAirTv() => _tvs(remote.onTheAirTv);
  @override
  Future<Either<Failure, List<Tv>>> getPopularTv() => _tvs(remote.popularTv);
  @override
  Future<Either<Failure, List<Tv>>> getTopRatedTv() => _tvs(remote.topRatedTv);
}
