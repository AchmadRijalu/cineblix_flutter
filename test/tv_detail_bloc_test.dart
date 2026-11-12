import 'package:cineblix_flutter/domain/use_cases/use_cases.dart';
import 'package:cineblix_flutter/presentation/tv_detail/tv_detail.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'helpers/fakes.dart';

TvDetailBloc build({
  FakeTvDetailRepository? tv,
  FakeWatchlistRepository? watchlist,
}) {
  final t = tv ?? FakeTvDetailRepository();
  final w = watchlist ?? FakeWatchlistRepository();
  return TvDetailBloc(
    GetTvDetail(t),
    GetTvRecommendations(t),
    GetWatchlistStatus(w),
    SaveWatchlist(w),
    RemoveWatchlist(w),
  );
}

void main() {
  test(
    'fetch emits Loading then Loaded with recommendations and status',
    () async {
      final bloc = build();
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
    final bloc = build(
      tv: FakeTvDetailRepository(
        recommendations: const Left(ServerFailure('boom')),
      ),
    );
    bloc.add(const TvDetailFetched(1));
    await expectLater(
      bloc.stream,
      emitsInOrder([TvDetailLoading(), const TvDetailLoaded(dark, [], false)]),
    );
  });

  test('detail failure emits Error with the failure message', () async {
    final bloc = build(
      tv: FakeTvDetailRepository(
        detail: const Left(ServerFailure('not found')),
      ),
    );
    bloc.add(const TvDetailFetched(1));
    await expectLater(
      bloc.stream,
      emitsInOrder([TvDetailLoading(), const TvDetailError('not found')]),
    );
  });

  test('toggle adds then removes with messages', () async {
    final bloc = build();
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
    final bloc = build(watchlist: w);
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

  test(
    'watchlist status failure still shows the show as not in watchlist',
    () async {
      final bloc = build(
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
    },
  );

  test('toggle before load is ignored', () async {
    final w = FakeWatchlistRepository();
    final bloc = build(watchlist: w);
    bloc.add(TvDetailWatchlistToggled());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state, TvDetailInitial());
    expect(w.items, isEmpty);
  });
}
