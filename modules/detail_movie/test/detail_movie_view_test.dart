import 'package:core/core.dart';
import 'package:detail_movie/detail_movie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snackify/enums/snack_enums.dart';
import 'package:snackify/snack_type_details.dart';
import 'package:test_support/test_support.dart';
import 'package:watchlist/testing.dart';
import 'package:watchlist/watchlist.dart';

import 'detail_movie_bloc_test.dart' show routes;

Finder addToWatchlist() => find.descendant(
  of: find.byType(AppBar),
  matching: find.byTooltip('Add to Watchlist'),
);

Finder removeFromWatchlist() => find.descendant(
  of: find.byType(AppBar),
  matching: find.byTooltip('Remove from Watchlist'),
);

Future<void> expectSnack(
  WidgetTester tester,
  String message,
  SnackType type,
) async {
  expect(find.byType(SnackBar), findsNothing);
  expect(find.text(message), findsOneWidget);
  expect(find.byIcon(getPurposeDetails(type).icon), findsOneWidget);
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

Future<List<int>> openMovie(
  WidgetTester tester,
  Map<String, (int, Object)> routes, {
  FakeWatchlistRepository? store,
}) async {
  final locator = GetIt.instance..allowReassignment = true;
  locator.registerSingleton(fakeDio(routes));
  initWatchlist(locator);
  locator.registerSingleton<WatchlistRepository>(
    store ?? FakeWatchlistRepository(),
  );
  initDetailMovie(locator);
  final tapped = <int>[];
  await tester.pumpWidget(
    MaterialApp(
      home: DetailMovieView(
        id: 1,
        onRecommendationTap: (_, id) => tapped.add(id),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tapped;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(GetIt.instance.reset);

  testWidgets('shows poster, title, details and synopsis', (tester) async {
    await openMovie(tester, routes);
    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('Action · 148 min · ★ 8.4'), findsOneWidget);
    expect(find.text('Dreams within dreams.'), findsOneWidget);
    expect(find.byType(PosterCard), findsWidgets);
  });

  testWidgets('a recommendation reports its id', (tester) async {
    final tapped = await openMovie(tester, routes);
    await tester.scrollUntilVisible(
      find.text('Recommendations'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PosterCard).at(1));
    expect(tapped, [1]);
  });

  testWidgets('the heart adds the movie', (tester) async {
    final store = FakeWatchlistRepository();
    await openMovie(tester, routes, store: store);

    await tester.tap(addToWatchlist());
    await tester.pumpAndSettle();
    await expectSnack(tester, 'Added to Watchlist', SnackType.success);
    expect(removeFromWatchlist(), findsOneWidget);
    expect(store.items.single.title, 'Inception');
  });

  testWidgets('the heart removes a saved movie', (tester) async {
    final store = FakeWatchlistRepository(
      initial: [
        const MediaItem(
          id: 1,
          type: MediaType.movie,
          title: 'Inception',
          voteAverage: 8.4,
        ),
      ],
    );
    await openMovie(tester, routes, store: store);

    await tester.tap(removeFromWatchlist());
    await tester.pumpAndSettle();
    await expectSnack(tester, 'Removed from Watchlist', SnackType.success);
    expect(addToWatchlist(), findsOneWidget);
    expect(store.items, isEmpty);
  });

  testWidgets('a failed save shows an error snack and keeps the heart empty', (
    tester,
  ) async {
    await openMovie(
      tester,
      routes,
      store: FakeWatchlistRepository(
        failSave: const DatabaseFailure('disk full'),
      ),
    );
    await tester.tap(addToWatchlist());
    await tester.pump();
    await expectSnack(tester, 'disk full', SnackType.error);
    expect(addToWatchlist(), findsOneWidget);
  });

  testWidgets('an error offers retry', (tester) async {
    await openMovie(tester, {});
    expect(find.text('not found'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('not found'), findsOneWidget);
  });
}
