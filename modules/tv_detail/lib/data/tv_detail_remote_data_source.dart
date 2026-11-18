part of 'data.dart';

class TvDetailRemoteDataSource {
  final Dio dio;
  TvDetailRemoteDataSource(this.dio);

  Future<TvDetailModel> detail(int id) async =>
      TvDetailModel((await dio.get('/tv/$id')).data);

  Future<List<TvModel>> recommendations(int id) async =>
      TvModel.listFromJson((await dio.get('/tv/$id/recommendations')).data);
}
