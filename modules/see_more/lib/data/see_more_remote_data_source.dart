part of 'data.dart';

class SeeMoreRemoteDataSource {
  final Dio dio;
  SeeMoreRemoteDataSource(this.dio);

  Future<SeeMoreResult> items(MediaCategory category, int page) async {
    final path = switch (category) {
      MediaCategory.nowPlaying => '/movie/now_playing',
      MediaCategory.popularMovies => '/movie/popular',
      MediaCategory.topRatedMovies => '/movie/top_rated',
      MediaCategory.onTheAir => '/tv/on_the_air',
      MediaCategory.popularTv => '/tv/popular',
      MediaCategory.topRatedTv => '/tv/top_rated',
    };
    final data = (await dio.get(path, queryParameters: {'page': page})).data;
    return SeeMoreResult(
      items: [
        for (final json in data['results'] as List)
          SeeMoreItemModel.fromJson(category.type, json).toEntity(),
      ],
      page: data['page'],
      totalPages: data['total_pages'],
    );
  }
}
