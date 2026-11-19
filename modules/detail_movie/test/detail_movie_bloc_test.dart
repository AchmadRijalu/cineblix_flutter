import 'package:core/core.dart';
import 'package:detail_movie/data/data.dart';
import 'package:detail_movie/domain/domain.dart';
import 'package:detail_movie/presentation/presentation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:test_support/test_support.dart';
import 'package:watchlist/testing.dart';
import 'package:watchlist/watchlist.dart';

const movieDetailJson = {
  'id': 1,
  'title': 'Inception',
  'overview': 'Dreams within dreams.',
  'poster_path': null,
  'release_date': '2010-07-16',
  'runtime': 148,
  'vote_average': 8.4,
  'genres': [
    {'id': 28, 'name': 'Action'},
  ],
};

Map<String, dynamic> recommendations() => {
  'results': [
    for (var i = 1; i <= 3; i++)
      {
        'id': i,
        'title': 'Rec $i',
        'overview': 'Rec overview $i',
        'poster_path': null,
      },
  ],
};

final routes = <String, (int, Object)>{
  '/movie/1': (200, movieDetailJson),
  '/movie/1/recommendations': (200, recommendations()),
};

const inception = MovieDetail(
  id: 1,
  title: 'Inception',
  overview: 'Dreams within dreams.',
  posterPath: null,
  releaseDate: '2010-07-16',
  runtime: 148,
  voteAverage: 8.4,
  genres: ['Action'],
);

const inceptionItem = MediaItem(
  id: 1,
  type: MediaType.movie,
  title: 'Inception',
  overview: 'Dreams within dreams.',
  voteAverage: 8.4,
);

const darkItem = MediaItem(
  id: 1,
  type: MediaType.tv,
  title: 'Dark',
  voteAverage: 8.4,
);

DetailMovieRepositoryImpl repository(
  Map<String, (int, Object)> routes, {
  List<RequestOptions>? log,
}) => DetailMovieRepositoryImpl(
  DetailMovieRemoteDataSource(fakeDio(routes, log: log)),
);

DetailMovieBloc build(
  Map<String, (int, Object)> routes, {
  FakeWatchlistRepository? watchlist,
}) {
  final repo = repository(routes);
  final w = watchlist ?? FakeWatchlistRepository();
  return DetailMovieBloc(
    GetMovieDetail(repo),
    GetMovieRecommendations(repo),
    GetWatchlistStatus(w),
    SaveWatchlist(w),
    RemoveWatchlist(w),
  );
}

void main() {
  group('data', () {
    test('detail maps every field', () async {
      final log = <RequestOptions>[];
      expect(
        await GetMovieDetail(repository(routes, log: log))(1),
        const Right<Failure, MovieDetail>(inception),
      );
      expect(log.single.path, '/movie/1');
    });

    test('detail tolerates missing optional fields', () {
      expect(
        const MovieDetailModel({'id': 2}).toEntity(),
        const MovieDetail(
          id: 2,
          title: '',
          overview: '',
          posterPath: null,
          releaseDate: '',
          runtime: 0,
          voteAverage: 0,
          genres: [],
        ),
      );
    });

    test('recommendations map results', () async {
      final result = (await GetMovieRecommendations(repository(routes))(
        1,
      )).getOrElse((_) => []);
      expect(result.map((m) => m.title), ['Rec 1', 'Rec 2', 'Rec 3']);
      expect(
        result.first,
        const Movie(id: 1, title: 'Rec 1', overview: 'Rec overview 1'),
      );
    });

    test('an unknown movie is a ServerFailure', () async {
      expect(
        await repository({}).getMovieDetail(99),
        const Left<Failure, MovieDetail>(ServerFailure('not found')),
      );
    });
  });

  group('bloc', () {
    test(
      'emits Loading then Loaded with recommendations and watchlist status',
      () async {
        final bloc = build(
          routes,
          watchlist: FakeWatchlistRepository(initial: [inceptionItem]),
        );
        bloc.add(const DetailMovieFetched(1));
        await expectLater(
          bloc.stream,
          emitsInOrder([DetailMovieLoading(), isA<DetailMovieLoaded>()]),
        );
        final s = bloc.state as DetailMovieLoaded;
        expect(s.movie.title, 'Inception');
        expect(s.recommendations.map((m) => m.title), [
          'Rec 1',
          'Rec 2',
          'Rec 3',
        ]);
        expect(s.isAddedToWatchlist, isTrue);
      },
    );

    test(
      'a series with the same id does not mark the movie as added',
      () async {
        final bloc = build(
          routes,
          watchlist: FakeWatchlistRepository(initial: [darkItem]),
        );
        bloc.add(const DetailMovieFetched(1));
        await bloc.stream.firstWhere((s) => s is DetailMovieLoaded);
        expect((bloc.state as DetailMovieLoaded).isAddedToWatchlist, isFalse);
      },
    );

    test('recommendations failure still shows the movie', () async {
      final bloc = build({'/movie/1': (200, movieDetailJson)});
      bloc.add(const DetailMovieFetched(1));
      await expectLater(
        bloc.stream,
        emitsInOrder([DetailMovieLoading(), isA<DetailMovieLoaded>()]),
      );
      expect((bloc.state as DetailMovieLoaded).recommendations, isEmpty);
    });

    test('detail failure emits Error', () async {
      final bloc = build({});
      bloc.add(const DetailMovieFetched(1));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          DetailMovieLoading(),
          const DetailMovieError('not found'),
        ]),
      );
    });

    test('toggle adds the movie then removes it, with messages', () async {
      final w = FakeWatchlistRepository();
      final bloc = build(routes, watchlist: w);
      bloc.add(const DetailMovieFetched(1));
      await bloc.stream.firstWhere((s) => s is DetailMovieLoaded);

      bloc.add(DetailMovieWatchlistToggled());
      var s = await bloc.stream.first as DetailMovieLoaded;
      expect(
        (s.isAddedToWatchlist, s.watchlistMessage, s.watchlistFailed),
        (true, 'Added to Watchlist', false),
      );
      expect(w.items.single, inceptionItem);

      bloc.add(DetailMovieWatchlistToggled());
      s = await bloc.stream.first as DetailMovieLoaded;
      expect(
        (s.isAddedToWatchlist, s.watchlistMessage),
        (false, 'Removed from Watchlist'),
      );
      expect(w.items, isEmpty);
    });

    test('toggle failure keeps the flag and reports the error', () async {
      final bloc = build(
        routes,
        watchlist: FakeWatchlistRepository(
          failSave: const DatabaseFailure('disk full'),
        ),
      );
      bloc.add(const DetailMovieFetched(1));
      await bloc.stream.firstWhere((s) => s is DetailMovieLoaded);

      bloc.add(DetailMovieWatchlistToggled());
      final s = await bloc.stream.first as DetailMovieLoaded;
      expect(
        (s.isAddedToWatchlist, s.watchlistMessage, s.watchlistFailed),
        (false, 'disk full', true),
      );
    });

    test('a failing status read shows the movie as not saved', () async {
      final bloc = build(
        routes,
        watchlist: FakeWatchlistRepository(
          failStatus: const DatabaseFailure('locked'),
        ),
      );
      bloc.add(const DetailMovieFetched(1));
      await bloc.stream.firstWhere((s) => s is DetailMovieLoaded);
      expect((bloc.state as DetailMovieLoaded).isAddedToWatchlist, isFalse);
    });

    test('toggle before load is ignored', () async {
      final w = FakeWatchlistRepository();
      final bloc = build(routes, watchlist: w);
      bloc.add(DetailMovieWatchlistToggled());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, DetailMovieInitial());
      expect(w.items, isEmpty);
    });

    test('events compare by id', () {
      expect(const DetailMovieFetched(1), const DetailMovieFetched(1));
      expect(const DetailMovieFetched(1), isNot(const DetailMovieFetched(2)));
      expect(DetailMovieWatchlistToggled(), DetailMovieWatchlistToggled());
    });
  });
}
