import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist/domain/domain.dart';
import 'package:watchlist/presentation/presentation.dart';
import 'package:watchlist/testing.dart';

import 'helpers/items.dart';

void main() {
  test(
    'fetch emits Loading then Loaded with stored movies and shows',
    () async {
      final bloc = WatchlistBloc(
        GetWatchlist(
          FakeWatchlistRepository(initial: [darkItem, inceptionItem]),
        ),
      );
      bloc.add(WatchlistFetched());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          WatchlistLoading(),
          const WatchlistLoaded([darkItem, inceptionItem]),
        ]),
      );
    },
  );

  test('empty watchlist emits Loaded([])', () async {
    final bloc = WatchlistBloc(GetWatchlist(FakeWatchlistRepository()));
    bloc.add(WatchlistFetched());
    await expectLater(
      bloc.stream,
      emitsInOrder([WatchlistLoading(), const WatchlistLoaded([])]),
    );
  });

  test('storage failure emits WatchlistError', () async {
    final bloc = WatchlistBloc(
      GetWatchlist(
        FakeWatchlistRepository(failGet: const DatabaseFailure('x')),
      ),
    );
    bloc.add(WatchlistFetched());
    await expectLater(
      bloc.stream,
      emitsInOrder([WatchlistLoading(), const WatchlistError('x')]),
    );
  });
}
