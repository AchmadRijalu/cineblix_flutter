import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:see_more/data/data.dart';
import 'package:see_more/domain/domain.dart';
import 'package:test_support/test_support.dart';

Map<String, dynamic> list(
  String key, {
  required String prefix,
  int page = 1,
  int totalPages = 1,
}) => {
  'page': page,
  'total_pages': totalPages,
  'results': [
    for (var i = 1; i <= 2; i++)
      {
        'id': i,
        key: '$prefix $i',
        'overview': '$prefix overview $i',
        'poster_path': null,
      },
  ],
};

final routes = <String, (int, Object)>{
  '/movie/now_playing': (200, list('title', prefix: 'Now')),
  '/movie/popular': (200, list('title', prefix: 'Pop', totalPages: 2)),
  '/movie/top_rated': (200, list('title', prefix: 'Top')),
  '/tv/on_the_air': (200, list('name', prefix: 'Air')),
  '/tv/popular': (200, list('name', prefix: 'TvPop', totalPages: 2)),
  '/tv/top_rated': (200, list('name', prefix: 'TvTop')),
};

SeeMoreRepositoryImpl repo(
  Map<String, (int, Object)> routes, {
  List<RequestOptions>? log,
}) => SeeMoreRepositoryImpl(SeeMoreRemoteDataSource(fakeDio(routes, log: log)));

void main() {
  test('movie categories page through the movie lists', () async {
    final log = <RequestOptions>[];
    final useCase = GetSeeMoreItems(repo(routes, log: log));

    final popular = (await useCase(
      MediaCategory.popularMovies,
      2,
    )).getOrElse((_) => throw 'fail');
    expect(
      popular.items.first,
      const SeeMoreItem(
        id: 1,
        type: MediaType.movie,
        title: 'Pop 1',
        overview: 'Pop overview 1',
      ),
    );
    expect(popular.hasMore, isTrue);
    expect(
      (await useCase(
        MediaCategory.topRatedMovies,
        1,
      )).getOrElse((_) => throw 'fail').hasMore,
      isFalse,
    );
    expect((await useCase(MediaCategory.nowPlaying, 1)).isRight(), isTrue);

    expect(log.map((r) => r.path), [
      '/movie/popular',
      '/movie/top_rated',
      '/movie/now_playing',
    ]);
    expect(log.first.queryParameters['page'], 2);
  });

  test('TV categories page through the TV lists', () async {
    final log = <RequestOptions>[];
    final useCase = GetSeeMoreItems(repo(routes, log: log));

    final onTheAir = (await useCase(
      MediaCategory.onTheAir,
      1,
    )).getOrElse((_) => throw 'fail');
    expect(
      onTheAir.items.first,
      const SeeMoreItem(
        id: 1,
        type: MediaType.tv,
        title: 'Air 1',
        overview: 'Air overview 1',
      ),
    );
    expect((await useCase(MediaCategory.popularTv, 2)).isRight(), isTrue);
    expect((await useCase(MediaCategory.topRatedTv, 1)).isRight(), isTrue);
    expect(log.map((r) => r.path), [
      '/tv/on_the_air',
      '/tv/popular',
      '/tv/top_rated',
    ]);
  });

  test('a missing title or name becomes an empty string', () {
    expect(
      SeeMoreItemModel.fromJson(MediaType.tv, const {'id': 3}).toEntity(),
      const SeeMoreItem(id: 3, type: MediaType.tv, title: ''),
    );
  });

  test('an HTTP error becomes a ServerFailure', () async {
    expect(
      await repo({}).getItems(MediaCategory.popularMovies, 1),
      const Left<Failure, SeeMoreResult>(ServerFailure('not found')),
    );
  });
}
