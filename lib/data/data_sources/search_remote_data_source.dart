part of 'data_sources.dart';

class SearchRemoteDataSource {
  final Dio dio;
  SearchRemoteDataSource(this.dio);

  Future<List<TvModel>> searchTv(String query) async => TvModel.listFromJson(
    (await dio.get('/search/tv', queryParameters: {'query': query})).data,
  );
}
