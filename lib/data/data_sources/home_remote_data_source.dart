part of 'data_sources.dart';

class HomeRemoteDataSource {
  final Dio dio;
  HomeRemoteDataSource(this.dio);

  Future<List<MovieModel>> _movies(String path) async =>
      MovieModel.listFromJson((await dio.get(path)).data);

  Future<List<TvModel>> _tvs(String path) async =>
      TvModel.listFromJson((await dio.get(path)).data);

  Future<List<MovieModel>> nowPlaying() => _movies('/movie/now_playing');
  Future<List<MovieModel>> popular() => _movies('/movie/popular');
  Future<List<MovieModel>> topRated() => _movies('/movie/top_rated');

  Future<List<TvModel>> onTheAirTv() => _tvs('/tv/on_the_air');
  Future<List<TvModel>> popularTv() => _tvs('/tv/popular');
  Future<List<TvModel>> topRatedTv() => _tvs('/tv/top_rated');
}
