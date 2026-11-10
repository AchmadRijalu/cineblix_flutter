import 'package:cineblix_flutter/common/commons.dart';
import 'package:cineblix_flutter/data/data_sources/data_sources.dart';
import 'package:cineblix_flutter/data/repositories/repositories.dart';
import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:cineblix_flutter/domain/use_cases/use_cases.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'helpers/fake_dio.dart';
import 'helpers/tmdb_fixtures.dart';

final dio = fakeDio(allRoutes);

void main() {
  group('Home', () {
    final repo = HomeRepositoryImpl(HomeRemoteDataSource(dio));

    test('now playing, popular and top rated map results to movies', () async {
      expect(
        (await GetNowPlayingMovies(repo)()).getOrElse((_) => []).first,
        const Movie(id: 1, title: 'Now 1', overview: 'Now overview 1'),
      );
      expect((await GetPopularMovies(repo)()).getOrElse((_) => []).length, 3);
      expect(
        (await GetTopRatedMovies(repo)()).getOrElse((_) => []).last.title,
        'Top 3',
      );
    });

    test('no network becomes ConnectionFailure', () async {
      final offline = HomeRepositoryImpl(
        HomeRemoteDataSource(fakeDio({'/movie/now_playing': (0, {})})),
      );
      expect(
        await offline.getNowPlayingMovies(),
        const Left<Failure, List<Movie>>(
          ConnectionFailure('Failed to connect to the network'),
        ),
      );
    });

    test(
      'error body without status_message falls back to the status code',
      () async {
        final broken = HomeRepositoryImpl(
          HomeRemoteDataSource(fakeDio({'/movie/popular': (500, 'oops')})),
        );
        expect(
          await broken.getPopularMovies(),
          const Left<Failure, List<Movie>>(ServerFailure('Server error (500)')),
        );
      },
    );
  });

  group('Detail movie', () {
    final repo = DetailMovieRepositoryImpl(DetailMovieRemoteDataSource(dio));

    test('detail maps every field', () async {
      expect(
        (await GetMovieDetail(repo)(1)).getOrElse((_) => throw 'fail'),
        const MovieDetail(
          id: 1,
          title: 'Inception',
          overview: 'Dreams within dreams.',
          posterPath: null,
          releaseDate: '2010-07-16',
          runtime: 148,
          voteAverage: 8.4,
          genres: ['Action'],
        ),
      );
    });

    test('recommendations map results', () async {
      expect(
        (await GetMovieRecommendations(repo)(
          1,
        )).getOrElse((_) => []).first.title,
        'Rec 1',
      );
    });

    test('unknown movie is a ServerFailure', () async {
      expect((await repo.getMovieDetail(99)).isLeft(), isTrue);
    });
  });

  group('See more', () {
    test('movie categories page through the movie lists', () async {
      final repo = SeeMoreRepositoryImpl(SeeMoreRemoteDataSource(dio));
      final popular = (await GetSeeMoreItems(repo)(
        MediaCategory.popularMovies,
        1,
      )).getOrElse((_) => throw 'fail');
      expect(
        popular.items.first,
        const MediaItem(
          id: 1,
          type: MediaType.movie,
          title: 'Pop 1',
          overview: 'Pop overview 1',
          voteAverage: 0,
        ),
      );
      expect(popular.hasMore, isTrue);
      expect(
        (await repo.getItems(
          MediaCategory.topRatedMovies,
          1,
        )).getOrElse((_) => throw 'fail').hasMore,
        isFalse,
      );
      expect(
        (await repo.getItems(MediaCategory.nowPlaying, 1)).isRight(),
        isTrue,
      );
    });

    test('TV categories page through the TV lists', () async {
      final log = <RequestOptions>[];
      final repo = SeeMoreRepositoryImpl(
        SeeMoreRemoteDataSource(fakeDio(allRoutes, log: log)),
      );
      final onTheAir = (await repo.getItems(
        MediaCategory.onTheAir,
        1,
      )).getOrElse((_) => throw 'fail');
      expect(
        onTheAir.items.first,
        const MediaItem(
          id: 1,
          type: MediaType.tv,
          title: 'Air 1',
          overview: 'Air overview 1',
          voteAverage: 7.5,
        ),
      );
      expect(
        (await repo.getItems(MediaCategory.popularTv, 2)).isRight(),
        isTrue,
      );
      expect(
        (await repo.getItems(MediaCategory.topRatedTv, 1)).isRight(),
        isTrue,
      );
      expect(log.map((r) => r.path), [
        '/tv/on_the_air',
        '/tv/popular',
        '/tv/top_rated',
      ]);
      expect(log[1].queryParameters['page'], 2);
    });
  });

  group('Search', () {
    test('repository maps results and failures', () async {
      expect(
        (await SearchTv(SearchRepositoryImpl(SearchRemoteDataSource(dio)))(
          'Dark',
        )).getOrElse((_) => []),
        [
          const Tv(
            id: 1,
            name: 'Dark',
            overview: 'Time travel in Winden.',
            voteAverage: 8.4,
          ),
        ],
      );
      expect(
        (await SearchRepositoryImpl(
          SearchRemoteDataSource(fakeDio({})),
        ).searchTv('x')).isLeft(),
        isTrue,
      );
    });
  });

  test('createDio refuses to run without an API key', () {
    expect(createDio, throwsStateError);
  });
}
