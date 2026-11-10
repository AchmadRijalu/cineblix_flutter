part of 'data_sources.dart';

class DetailMovieRemoteDataSource {
  final Dio dio;
  DetailMovieRemoteDataSource(this.dio);

  Future<MovieDetailModel> detail(int id) async =>
      MovieDetailModel((await dio.get('/movie/$id')).data);

  Future<List<MovieModel>> recommendations(int id) async =>
      MovieModel.listFromJson(
        (await dio.get('/movie/$id/recommendations')).data,
      );
}
