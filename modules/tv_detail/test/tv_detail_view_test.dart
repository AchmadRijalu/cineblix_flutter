import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snackify/enums/snack_enums.dart';
import 'package:snackify/snack_type_details.dart';
import 'package:test_support/test_support.dart';
import 'package:tv_detail/tv_detail.dart';
import 'package:watchlist/testing.dart';
import 'package:watchlist/watchlist.dart';

import 'tv_detail_bloc_test.dart' show routes, tvDetailJson;

typedef Taps = ({List<int> recommendations, List<(int, int, String)> seasons});

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

Future<Taps> openTv(
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
  initTvDetail(locator);
  final taps = (recommendations: <int>[], seasons: <(int, int, String)>[]);
  await tester.pumpWidget(
    MaterialApp(
      home: TvDetailView(
        id: 1,
        onRecommendationTap: (_, id) => taps.recommendations.add(id),
        onSeasonTap: (_, tvId, number, title) =>
            taps.seasons.add((tvId, number, title)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return taps;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(GetIt.instance.reset);

  testWidgets('shows poster, title, rating, synopsis and seasons', (
    tester,
  ) async {
    await openTv(tester, routes);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('★ 8.4'), findsOneWidget);
    expect(find.text('Drama · 3 seasons'), findsOneWidget);
    expect(find.text('Time travel in Winden.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Season 2'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Seasons'), findsOneWidget);
    expect(find.text('10 episodes · 2017'), findsOneWidget);
    expect(find.text('8 episodes · 2019'), findsOneWidget);
  });

  testWidgets('a season reports its tv id, number and title', (tester) async {
    final taps = await openTv(tester, routes);
    await tester.scrollUntilVisible(
      find.text('Season 1'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Season 1'));
    expect(taps.seasons, [(1, 1, 'Season 1')]);
  });

  testWidgets('a recommendation reports its id', (tester) async {
    final taps = await openTv(tester, routes);
    await tester.scrollUntilVisible(
      find.text('Recommendations'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PosterCard).last);
    expect(taps.recommendations, [2]);
  });

  testWidgets('a show without synopsis, genres or seasons still renders', (
    tester,
  ) async {
    await openTv(tester, {
      '/tv/1': (
        200,
        {
          ...tvDetailJson,
          'overview': '',
          'genres': [],
          'seasons': [],
          'number_of_seasons': 1,
        },
      ),
    });
    expect(find.text('No synopsis available.'), findsOneWidget);
    expect(find.text('1 season'), findsOneWidget);
    expect(find.text('Seasons'), findsNothing);
    expect(find.text('No recommendations.'), findsOneWidget);
  });

  testWidgets('the heart adds the show', (tester) async {
    final store = FakeWatchlistRepository();
    await openTv(tester, routes, store: store);

    await tester.tap(addToWatchlist());
    await tester.pumpAndSettle();
    await expectSnack(tester, 'Added to Watchlist', SnackType.success);
    expect(removeFromWatchlist(), findsOneWidget);
    expect(store.items.single.title, 'Dark');
  });

  testWidgets('the heart removes a saved show', (tester) async {
    final store = FakeWatchlistRepository(
      initial: [
        const MediaItem(
          id: 1,
          type: MediaType.tv,
          title: 'Dark',
          voteAverage: 8.4,
        ),
      ],
    );
    await openTv(tester, routes, store: store);

    await tester.tap(removeFromWatchlist());
    await tester.pumpAndSettle();
    await expectSnack(tester, 'Removed from Watchlist', SnackType.success);
    expect(store.items, isEmpty);
  });

  testWidgets('a failed save shows an error snack and keeps the heart empty', (
    tester,
  ) async {
    await openTv(
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
    await openTv(tester, {});
    expect(find.text('not found'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('not found'), findsOneWidget);
  });
}
