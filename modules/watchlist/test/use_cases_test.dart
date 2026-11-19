import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:watchlist/presentation/presentation.dart';
import 'package:watchlist/testing.dart';
import 'package:watchlist/watchlist.dart';

import 'helpers/items.dart';

void main() {
  test(
    'save, status and remove keep a movie and a series with the same id apart',
    () async {
      final repo = FakeWatchlistRepository();
      final save = SaveWatchlist(repo);
      final status = GetWatchlistStatus(repo);
      final remove = RemoveWatchlist(repo);

      expect(
        await save(darkItem),
        const Right<Failure, String>('Added to Watchlist'),
      );
      expect(await status(1, MediaType.tv), const Right<Failure, bool>(true));
      expect(
        await status(1, MediaType.movie),
        const Right<Failure, bool>(false),
      );

      await save(darkItem);
      expect(repo.items, [darkItem]);

      expect(
        await remove(1, MediaType.tv),
        const Right<Failure, String>('Removed from Watchlist'),
      );
      expect(await status(1, MediaType.tv), const Right<Failure, bool>(false));
    },
  );

  test('failures are reported, not thrown', () async {
    final repo = FakeWatchlistRepository(
      failSave: const DatabaseFailure('disk full'),
      failStatus: const DatabaseFailure('locked'),
      failGet: const DatabaseFailure('gone'),
    );
    expect(
      await SaveWatchlist(repo)(darkItem),
      const Left<Failure, String>(DatabaseFailure('disk full')),
    );
    expect(
      await GetWatchlistStatus(repo)(1, MediaType.tv),
      const Left<Failure, bool>(DatabaseFailure('locked')),
    );
    expect(
      await GetWatchlist(repo)(),
      const Left<Failure, List<MediaItem>>(DatabaseFailure('gone')),
    );
  });

  test('initWatchlist registers everything the app needs', () {
    final locator = GetIt.asNewInstance();
    initWatchlist(locator);
    expect(locator<SaveWatchlist>(), isA<SaveWatchlist>());
    expect(locator<RemoveWatchlist>(), isA<RemoveWatchlist>());
    expect(locator<GetWatchlistStatus>(), isA<GetWatchlistStatus>());
    expect(locator<GetWatchlist>(), isA<GetWatchlist>());
    expect(locator<WatchlistBloc>(), isA<WatchlistBloc>());
  });

  test('events compare by value', () {
    expect(WatchlistFetched(), WatchlistFetched());
  });
}
