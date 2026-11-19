import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:test_support/test_support.dart';
import 'package:tv_detail/data/data.dart';
import 'package:tv_detail/domain/domain.dart';
import 'package:tv_detail/presentation/presentation.dart';
import 'package:watchlist/testing.dart';
import 'package:watchlist/watchlist.dart';

const tvDetailJson = {
  'id': 1,
  'name': 'Dark',
  'overview': 'Time travel in Winden.',
  'poster_path': '/p.jpg',
  'vote_average': 8.4,
  'genres': [
    {'id': 18, 'name': 'Drama'},
  ],
  'number_of_seasons': 3,
  'first_air_date': '2017-12-01',
  'seasons': [
    {
      'season_number': 1,
      'name': 'Season 1',
      'episode_count': 10,
      'poster_path': null,
      'air_date': '2017-12-01',
    },
    {
      'season_number': 2,
      'name': 'Season 2',
      'episode_count': 8,
      'poster_path': null,
      'air_date': '2019-06-21',
    },
  ],
};

const recommendationsJson = {
  'results': [
    {'id': 2, 'name': '1899', 'overview': null, 'poster_path': null},
  ],
};

final routes = <String, (int, Object)>{
  '/tv/1': (200, tvDetailJson),
  '/tv/1/recommendations': (200, recommendationsJson),
};

const dark = TvDetail(
  id: 1,
  name: 'Dark',
  overview: 'Time travel in Winden.',
  posterPath: '/p.jpg',
  voteAverage: 8.4,
  genres: ['Drama'],
  numberOfSeasons: 3,
  firstAirDate: '2017-12-01',
  seasons: [
    Season(
      seasonNumber: 1,
      name: 'Season 1',
      episodeCount: 10,
      posterPath: null,
      airDate: '2017-12-01',
    ),
    Season(
      seasonNumber: 2,
      name: 'Season 2',
      episodeCount: 8,
      posterPath: null,
      airDate: '2019-06-21',
    ),
  ],
);

const show1899 = Tv(id: 2, name: '1899');

const darkItem = MediaItem(
  id: 1,
  type: MediaType.tv,
  title: 'Dark',
  overview: 'Time travel in Winden.',
  posterPath: '/p.jpg',
  voteAverage: 8.4,
);

const inceptionItem = MediaItem(
  id: 1,
  type: MediaType.movie,
  title: 'Inception',
  voteAverage: 8.4,
);

TvDetailRepositoryImpl repository(
  Map<String, (int, Object)> routes, {
  List<RequestOptions>? log,
}) =>
    TvDetailRepositoryImpl(TvDetailRemoteDataSource(fakeDio(routes, log: log)));

TvDetailBloc build(
  Map<String, (int, Object)> routes, {
  FakeWatchlistRepository? watchlist,
}) {
  final repo = repository(routes);
  final w = watchlist ?? FakeWatchlistRepository();
  return TvDetailBloc(
    GetTvDetail(repo),
    GetTvRecommendations(repo),
    GetWatchlistStatus(w),
    SaveWatchlist(w),
    RemoveWatchlist(w),
  );
}

void main() {
  group('models', () {
    test('TvModel parses a result with null poster/overview and no rating', () {
      expect(
        TvModel.fromJson(const {
          'id': 1,
          'name': 'Dark',
          'overview': null,
          'poster_path': null,
        }).toEntity(),
        const Tv(id: 1, name: 'Dark'),
      );
    });

    test('TvModel.listFromJson reads results and an int vote_average', () {
      final tv = TvModel.listFromJson(const {
        'results': [
          {'id': 2, 'name': '1899', 'vote_average': 7},
        ],
      }).single.toEntity();
      expect(tv, const Tv(id: 2, name: '1899', voteAverage: 7));
    });

    test('TvDetailModel maps genres, seasons and an int vote_average', () {
      expect(const TvDetailModel(tvDetailJson).toEntity(), dark);
      expect(
        const TvDetailModel({
          'id': 1,
          'name': 'Dark',
          'vote_average': 8,
        }).toEntity().voteAverage,
        8.0,
      );
    });

    test('TvDetailModel tolerates missing optional fields', () {
      expect(
        const TvDetailModel({'id': 1, 'name': 'Dark'}).toEntity(),
        const TvDetail(
          id: 1,
          name: 'Dark',
          overview: '',
          posterPath: null,
          voteAverage: 0,
          genres: [],
          numberOfSeasons: 0,
          firstAirDate: '',
        ),
      );
    });
  });

  group('repository', () {
    test('getTvDetail calls /tv/{id} and maps to entity', () async {
      final log = <RequestOptions>[];
      expect(
        await repository(routes, log: log).getTvDetail(1),
        const Right<Failure, TvDetail>(dark),
      );
      expect(log.single.path, '/tv/1');
    });

    test('getTvRecommendations calls /tv/{id}/recommendations', () async {
      expect(
        (await GetTvRecommendations(repository(routes))(
          1,
        )).getOrElse((_) => []),
        [show1899],
      );
    });

    test(
      'an HTTP error becomes a ServerFailure with the TMDB message',
      () async {
        expect(
          await repository({}).getTvDetail(99),
          const Left<Failure, TvDetail>(ServerFailure('not found')),
        );
      },
    );
  });

  group('bloc', () {
    test(
      'fetch emits Loading then Loaded with recommendations and status',
      () async {
        final bloc = build(routes);
        bloc.add(const TvDetailFetched(1));
        await expectLater(
          bloc.stream,
          emitsInOrder([
            TvDetailLoading(),
            const TvDetailLoaded(dark, [show1899], false),
          ]),
        );
      },
    );

    test('recommendations failure still shows the show', () async {
      final bloc = build({'/tv/1': (200, tvDetailJson)});
      bloc.add(const TvDetailFetched(1));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          TvDetailLoading(),
          const TvDetailLoaded(dark, [], false),
        ]),
      );
    });

    test('detail failure emits Error with the failure message', () async {
      final bloc = build({});
      bloc.add(const TvDetailFetched(1));
      await expectLater(
        bloc.stream,
        emitsInOrder([TvDetailLoading(), const TvDetailError('not found')]),
      );
    });

    test('a failing status read shows the show as not saved', () async {
      final bloc = build(
        routes,
        watchlist: FakeWatchlistRepository(
          failStatus: const DatabaseFailure('locked'),
        ),
      );
      bloc.add(const TvDetailFetched(1));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          TvDetailLoading(),
          const TvDetailLoaded(dark, [show1899], false),
        ]),
      );
    });

    test('toggle adds then removes with messages', () async {
      final bloc = build(routes);
      bloc.add(const TvDetailFetched(1));
      await bloc.stream.firstWhere((s) => s is TvDetailLoaded);

      bloc.add(TvDetailWatchlistToggled());
      expect(
        await bloc.stream.first,
        const TvDetailLoaded(
          dark,
          [show1899],
          true,
          watchlistMessage: 'Added to Watchlist',
        ),
      );

      bloc.add(TvDetailWatchlistToggled());
      expect(
        await bloc.stream.first,
        const TvDetailLoaded(
          dark,
          [show1899],
          false,
          watchlistMessage: 'Removed from Watchlist',
        ),
      );
    });

    test('toggle stores the show as a TV watchlist item', () async {
      final w = FakeWatchlistRepository(initial: [inceptionItem]);
      final bloc = build(routes, watchlist: w);
      bloc.add(const TvDetailFetched(1));
      final loaded =
          await bloc.stream.firstWhere((s) => s is TvDetailLoaded)
              as TvDetailLoaded;
      expect(
        loaded.isAddedToWatchlist,
        isFalse,
        reason: 'a movie with the same id is not this show',
      );

      bloc.add(TvDetailWatchlistToggled());
      await bloc.stream.first;
      expect(w.items.first, darkItem);
    });

    test('toggle failure keeps the flag and reports the error', () async {
      final bloc = build(
        routes,
        watchlist: FakeWatchlistRepository(
          failSave: const DatabaseFailure('disk full'),
        ),
      );
      bloc.add(const TvDetailFetched(1));
      await bloc.stream.firstWhere((s) => s is TvDetailLoaded);

      bloc.add(TvDetailWatchlistToggled());
      expect(
        await bloc.stream.first,
        const TvDetailLoaded(
          dark,
          [show1899],
          false,
          watchlistMessage: 'disk full',
          watchlistFailed: true,
        ),
      );
    });

    test('toggle before load is ignored', () async {
      final w = FakeWatchlistRepository();
      final bloc = build(routes, watchlist: w);
      bloc.add(TvDetailWatchlistToggled());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, TvDetailInitial());
      expect(w.items, isEmpty);
    });

    test('events compare by value', () {
      expect(const TvDetailFetched(1), const TvDetailFetched(1));
      expect(const TvDetailFetched(1), isNot(const TvDetailFetched(2)));
      expect(TvDetailWatchlistToggled(), TvDetailWatchlistToggled());
    });
  });
}
