part of 'data_sources.dart';

class SeeMoreRemoteDataSource {
  final Dio dio;
  SeeMoreRemoteDataSource(this.dio);

  Future<MediaPage> items(MediaCategory category, int page) async {
    final path = switch (category) {
      MediaCategory.nowPlaying => '/movie/now_playing',
      MediaCategory.popularMovies => '/movie/popular',
      MediaCategory.topRatedMovies => '/movie/top_rated',
      MediaCategory.onTheAir => '/tv/on_the_air',
      MediaCategory.popularTv => '/tv/popular',
      MediaCategory.topRatedTv => '/tv/top_rated',
    };
    final data = (await dio.get(path, queryParameters: {'page': page})).data;
    return MediaPage(
      items: switch (category.type) {
        MediaType.movie => [
          for (final m in MovieModel.listFromJson(data)) m.toMediaItem(),
        ],
        MediaType.tv => [
          for (final t in TvModel.listFromJson(data)) t.toMediaItem(),
        ],
      },
      page: data['page'],
      totalPages: data['total_pages'],
    );
  }
}
