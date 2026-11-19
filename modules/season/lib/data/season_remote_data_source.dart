part of 'data.dart';

class SeasonRemoteDataSource {
  final Dio dio;
  SeasonRemoteDataSource(this.dio);

  Future<SeasonDetailModel> seasonDetail(int tvId, int seasonNumber) async =>
      SeasonDetailModel((await dio.get('/tv/$tvId/season/$seasonNumber')).data);
}
