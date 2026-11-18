import 'package:about/about.dart';
import 'package:cineblix_flutter/injection.dart';
import 'package:cineblix_flutter/main.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watchlist/testing.dart';
import 'package:watchlist/watchlist.dart';

import 'helpers/app_setup.dart';
import 'helpers/fixtures.dart';

const inception = MediaItem(
  id: 1,
  type: MediaType.movie,
  title: 'Inception',
  voteAverage: 8.4,
);

const dark = MediaItem(
  id: 1,
  type: MediaType.tv,
  title: 'Dark',
  voteAverage: 8.4,
);

Finder addToWatchlist() => find.descendant(
  of: find.byType(AppBar),
  matching: find.byTooltip('Add to Watchlist'),
);

Finder removeFromWatchlist() => find.descendant(
  of: find.byType(AppBar),
  matching: find.byTooltip('Remove from Watchlist'),
);

Future<void> openApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Future<void> openTvTab(WidgetTester tester) async {
  await tester.tap(find.text('TV Series'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(locator.reset);

  group('Home to details', () {
    testWidgets(
      'a movie poster opens its detail, and a recommendation opens on top',
      (tester) async {
        setUpApp();
        await openApp(tester);
        expect(find.text('Now Playing'), findsOneWidget);

        await tester.tap(find.byType(PosterCard).first);
        await tester.pumpAndSettle();
        expect(find.text('Inception'), findsOneWidget);
        expect(find.text('Dreams within dreams.'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Recommendations'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PosterCard).at(1));
        await tester.pumpAndSettle();
        expect(find.text('Inception', skipOffstage: false), findsNWidgets(2));

        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Now Playing'), findsOneWidget);
      },
    );

    testWidgets('a TV poster opens its detail with seasons', (tester) async {
      setUpApp();
      await openApp(tester);
      await openTvTab(tester);
      expect(find.text('On The Air'), findsOneWidget);

      await tester.tap(find.byType(PosterCard).first);
      await tester.pumpAndSettle();
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('★ 8.4'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Season 1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    });

    testWidgets('a season opens its episodes', (tester) async {
      setUpApp();
      await openApp(tester);
      await openTvTab(tester);
      await tester.tap(find.byType(PosterCard).first);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Season 1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('Season 1'));
      await tester.pumpAndSettle();
      expect(find.text('A child goes missing.'), findsOneWidget);
      expect(find.text('E1 · Secrets'), findsOneWidget);
    });
  });

  group('See More', () {
    testWidgets(
      'a movie section opens the list, and an item opens its detail',
      (tester) async {
        setUpApp();
        await openApp(tester);
        await tester.tap(find.text('See More').at(1));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(AppBar, 'Popular'), findsOneWidget);
        expect(find.text('Pop overview 1'), findsOneWidget);

        await tester.tap(find.text('Pop 1'));
        await tester.pumpAndSettle();
        expect(find.text('Inception'), findsOneWidget);
      },
    );

    testWidgets('a TV section opens the list, and an item opens its detail', (
      tester,
    ) async {
      setUpApp();
      await openApp(tester);
      await openTvTab(tester);
      await tester.tap(find.text('See More').at(1));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Popular'), findsOneWidget);
      expect(find.text('TvPop overview 1'), findsOneWidget);

      await tester.tap(find.text('TvPop 1'));
      await tester.pumpAndSettle();
      expect(find.text('Dark'), findsOneWidget);
    });
  });

  group('Search', () {
    testWidgets('searching from Home opens the TV detail of a result', (
      tester,
    ) async {
      setUpApp();
      await openApp(tester);
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.text('Type a title and press search'), findsOneWidget);

      await tester.enterText(find.byType(CustomFormField), 'Dark');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.textContaining('Time travel in Winden.'), findsOneWidget);

      await tester.tap(find.byType(PosterTile));
      await tester.pumpAndSettle();
      expect(find.text('★ 8.4'), findsOneWidget);
    });
  });

  group('Watchlist', () {
    testWidgets(
      'saving a movie shows it in the watchlist, and it opens again',
      (tester) async {
        setUpApp();
        await openApp(tester);
        await tester.tap(find.byType(PosterCard).first);
        await tester.pumpAndSettle();
        await tester.tap(addToWatchlist());
        await tester.pumpAndSettle();
        expect(watchlist.items.single.title, 'Inception');
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();

        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pumpAndSettle();
        expect(find.text('Inception'), findsOneWidget);

        await tester.tap(find.text('Inception'));
        await tester.pumpAndSettle();
        expect(removeFromWatchlist(), findsOneWidget);
      },
    );

    testWidgets('removing a series on its detail updates the list on return', (
      tester,
    ) async {
      setUpApp(store: FakeWatchlistRepository(initial: [dark, inception]));
      await openApp(tester);
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Inception'), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      await tester.tap(removeFromWatchlist());
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Dark'), findsNothing);
      expect(find.text('Inception'), findsOneWidget);
    });
  });

  testWidgets('the info icon opens the About page', (tester) async {
    setUpApp();
    await openApp(tester);
    await tester.tap(find.byIcon(Icons.info));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('Cineblix'), findsOneWidget);
  });

  testWidgets('every route that fails keeps the app usable', (tester) async {
    setUpApp(
      routes: {
        '/movie/now_playing': (200, movieList('Now')),
        '/movie/popular': (200, movieList('Pop')),
        '/movie/top_rated': (200, movieList('Top')),
      },
    );
    await openApp(tester);
    await openTvTab(tester);
    expect(find.text('not found'), findsOneWidget);
    await tester.tap(find.text('Movies'));
    await tester.pumpAndSettle();
    expect(find.text('Now Playing'), findsOneWidget);
  });
}
