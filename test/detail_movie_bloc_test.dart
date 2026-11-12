import 'package:cineblix_flutter/data/data_sources/data_sources.dart';
import 'package:cineblix_flutter/data/repositories/repositories.dart';
import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:cineblix_flutter/domain/use_cases/use_cases.dart';
import 'package:cineblix_flutter/presentation/detail_movie/detail_movie.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';
import 'helpers/fakes.dart';
import 'helpers/tmdb_fixtures.dart';

DetailMovieBloc build(
  Map<String, (int, Object)> routes, {
  FakeWatchlistRepository? watchlist,
}) {
  final repo = DetailMovieRepositoryImpl(
    DetailMovieRemoteDataSource(fakeDio(routes)),
  );
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
  test(
    'emits Loading then Loaded with recommendations and watchlist status',
    () async {
      final bloc = build(
        allRoutes,
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
    'a TV series with the same id does not mark the movie as added',
    () async {
      final bloc = build(
        allRoutes,
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
      emitsInOrder([DetailMovieLoading(), const DetailMovieError('not found')]),
    );
  });

  test('toggle adds the movie then removes it, with messages', () async {
    final w = FakeWatchlistRepository();
    final bloc = build(allRoutes, watchlist: w);
    bloc.add(const DetailMovieFetched(1));
    await bloc.stream.firstWhere((s) => s is DetailMovieLoaded);

    bloc.add(DetailMovieWatchlistToggled());
    var s = await bloc.stream.first as DetailMovieLoaded;
    expect(
      (s.isAddedToWatchlist, s.watchlistMessage, s.watchlistFailed),
      (true, 'Added to Watchlist', false),
    );
    expect(w.items.single.type, MediaType.movie);
    expect(w.items.single.title, 'Inception');

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
      allRoutes,
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

  test('toggle before load is ignored', () async {
    final w = FakeWatchlistRepository();
    final bloc = build(allRoutes, watchlist: w);
    bloc.add(DetailMovieWatchlistToggled());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state, DetailMovieInitial());
    expect(w.items, isEmpty);
  });

  test('events compare by id', () {
    expect(const DetailMovieFetched(1), const DetailMovieFetched(1));
    expect(const DetailMovieFetched(1), isNot(const DetailMovieFetched(2)));
  });
}
