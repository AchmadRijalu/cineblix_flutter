part of 'data.dart';

class SearchRemoteDataSource {
  final Dio dio;
  SearchRemoteDataSource(this.dio);

  Future<List<SearchResultModel>> searchTv(String query) async =>
      SearchResultModel.listFromJson(
        (await dio.get('/search/tv', queryParameters: {'query': query})).data,
      );
}
