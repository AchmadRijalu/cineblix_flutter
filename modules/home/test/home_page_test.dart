import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/home.dart';
import 'package:test_support/test_support.dart';

import 'home_bloc_test.dart' show movieList, routes;

class Taps {
  final movies = <int>[];
  final tvs = <int>[];
  final seeMore = <MediaCategory>[];
  final other = <String>[];
}

Future<Taps> openHome(
  WidgetTester tester,
  Map<String, (int, Object)> routes,
) async {
  GetIt.instance.registerSingleton(fakeDio(routes));
  initHome(GetIt.instance);
  final taps = Taps();
  await tester.pumpWidget(
    MaterialApp(
      home: HomePage(
        onMovieTap: (_, id) => taps.movies.add(id),
        onTvTap: (_, id) => taps.tvs.add(id),
        onSeeMore: (_, category) => taps.seeMore.add(category),
        onSearch: (_) => taps.other.add('search'),
        onWatchlist: (_) => taps.other.add('watchlist'),
        onAbout: (_) => taps.other.add('about'),
      ),
    ),
  );
  expect(find.byType(CustomLoadingAnimation), findsOneWidget);
  await tester.pumpAndSettle();
  return taps;
}

Future<void> openTvTab(WidgetTester tester) async {
  await tester.tap(find.text('TV Series'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(GetIt.instance.reset);

  group('Movies tab', () {
    testWidgets('shows the three movie sections', (tester) async {
      await openHome(tester, routes);
      expect(find.byType(CustomLoadingAnimation), findsNothing);
      expect(find.text('Now Playing'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('Top Rated'), findsOneWidget);
      expect(find.byType(PosterCard), findsNWidgets(9));
    });

    testWidgets('a poster reports the movie id', (tester) async {
      final taps = await openHome(tester, routes);
      await tester.tap(find.byType(PosterCard).first);
      expect(taps.movies, [1]);
    });

    testWidgets('See More reports its category', (tester) async {
      final taps = await openHome(tester, routes);
      await tester.tap(find.text('See More').at(1));
      expect(taps.seeMore, [MediaCategory.popularMovies]);
    });

    testWidgets('an error offers retry', (tester) async {
      await openHome(tester, {});
      expect(find.text('not found'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
    });

    testWidgets('pull to refresh reloads the sections', (tester) async {
      await openHome(tester, routes);
      await tester.fling(find.text('Now Playing'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Now Playing'), findsOneWidget);
    });
  });

  group('TV Series tab', () {
    testWidgets('shows On The Air, Popular and Top Rated series', (
      tester,
    ) async {
      await openHome(tester, routes);
      await openTvTab(tester);
      expect(find.text('On The Air'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('Top Rated'), findsOneWidget);
    });

    testWidgets('a poster reports the series id', (tester) async {
      final taps = await openHome(tester, routes);
      await openTvTab(tester);
      await tester.tap(find.byType(PosterCard).first);
      expect(taps.tvs, [1]);
    });

    testWidgets('See More reports its category', (tester) async {
      final taps = await openHome(tester, routes);
      await openTvTab(tester);
      await tester.tap(find.text('See More').first);
      expect(taps.seeMore, [MediaCategory.onTheAir]);
    });

    testWidgets('an error offers retry', (tester) async {
      await openHome(tester, {
        '/movie/now_playing': (200, movieList('Now')),
        '/movie/popular': (200, movieList('Pop')),
        '/movie/top_rated': (200, movieList('Top')),
      });
      await openTvTab(tester);
      expect(find.text('not found'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
    });

    testWidgets('pull to refresh reloads the TV sections', (tester) async {
      await openHome(tester, routes);
      await openTvTab(tester);
      await tester.fling(find.text('On The Air'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('On The Air'), findsOneWidget);
    });
  });

  testWidgets('the AppBar icons report search, watchlist and about', (
    tester,
  ) async {
    final taps = await openHome(tester, routes);
    await tester.tap(find.byIcon(Icons.search));
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.tap(find.byIcon(Icons.info));
    expect(taps.other, ['search', 'watchlist', 'about']);
  });
}
