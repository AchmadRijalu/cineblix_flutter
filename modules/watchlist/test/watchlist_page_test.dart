import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watchlist/testing.dart';
import 'package:watchlist/watchlist.dart';

import 'helpers/items.dart';

void useStore(FakeWatchlistRepository store) {
  final locator = GetIt.instance..allowReassignment = true;
  initWatchlist(locator);
  locator.registerSingleton<WatchlistRepository>(store);
}

Future<List<MediaItem>> openWatchlist(
  WidgetTester tester,
  FakeWatchlistRepository store,
) async {
  useStore(store);
  final tapped = <MediaItem>[];
  await tester.pumpWidget(
    MaterialApp(
      home: WatchlistPage(
        onItemTap: (_, item) async {
          tapped.add(item);
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tapped;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(GetIt.instance.reset);

  testWidgets('lists movies and shows and reports taps', (tester) async {
    final tapped = await openWatchlist(
      tester,
      FakeWatchlistRepository(initial: [darkItem, inceptionItem]),
    );
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Inception'), findsOneWidget);
    expect(find.textContaining('★ 8.4'), findsNWidgets(2));

    await tester.tap(find.text('Inception'));
    await tester.pumpAndSettle();
    expect(tapped, [inceptionItem]);
  });

  testWidgets('refreshes after returning from the tapped item', (tester) async {
    final store = FakeWatchlistRepository(initial: [darkItem]);
    useStore(store);
    await tester.pumpWidget(
      MaterialApp(
        home: WatchlistPage(
          onItemTap: (_, item) async {
            store.items.clear();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(find.text('Your watchlist is empty'), findsOneWidget);
  });

  testWidgets('empty watchlist shows a message', (tester) async {
    await openWatchlist(tester, FakeWatchlistRepository());
    expect(find.text('Your watchlist is empty'), findsOneWidget);
  });

  testWidgets('storage failure shows the error and retry reloads', (
    tester,
  ) async {
    await openWatchlist(
      tester,
      FakeWatchlistRepository(failGet: const DatabaseFailure('disk error')),
    );
    expect(find.text('disk error'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('disk error'), findsOneWidget);
  });
}
