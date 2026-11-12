import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:cineblix_flutter/injection.dart';
import 'package:cineblix_flutter/main.dart';
import 'package:cineblix_flutter/presentation/detail_movie/detail_movie.dart';
import 'package:cineblix_flutter/presentation/favorites/favorites.dart';
import 'package:cineblix_flutter/presentation/season/season.dart';
import 'package:cineblix_flutter/presentation/see_more/see_more.dart';
import 'package:cineblix_flutter/presentation/tv_detail/tv_detail.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search/search.dart';
import 'package:snackify/enums/snack_enums.dart';
import 'package:snackify/snack_type_details.dart';

import 'helpers/app_setup.dart';
import 'helpers/fakes.dart';
import 'helpers/tmdb_fixtures.dart';

Widget app(Widget home) => MaterialApp(home: home);

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

Finder addToWatchlist() => find.descendant(
  of: find.byType(AppBar),
  matching: find.byTooltip('Add to Watchlist'),
);
Finder removeFromWatchlist() => find.descendant(
  of: find.byType(AppBar),
  matching: find.byTooltip('Remove from Watchlist'),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(locator.reset);

  group('Home', () {
    testWidgets('shows the three movie sections', (tester) async {
      setUpApp();
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CustomLoadingAnimation), findsOneWidget);
      final barrier = tester.widget<ModalBarrier>(
        find.descendant(
          of: find.byType(CustomLoadingAnimation),
          matching: find.byType(ModalBarrier),
        ),
      );
      expect(barrier.color, Colors.transparent);
      await tester.pumpAndSettle();
      expect(find.byType(CustomLoadingAnimation), findsNothing);

      expect(find.text('Now Playing'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('Top Rated'), findsOneWidget);
      expect(find.byType(PosterCard), findsNWidgets(9));
    });

    testWidgets('pull to refresh reloads the sections', (tester) async {
      setUpApp();
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.fling(find.text('Now Playing'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Now Playing'), findsOneWidget);
    });

    testWidgets('error shows the message and retry reloads', (tester) async {
      setUpApp(routes: {});
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
    });

    testWidgets('poster opens movie detail with recommendations', (
      tester,
    ) async {
      setUpApp();
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PosterCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(DetailMovieView), findsOneWidget);
      expect(find.text('Inception'), findsOneWidget);
      expect(find.text('Dreams within dreams.'), findsOneWidget);
      expect(find.textContaining('148 min'), findsOneWidget);
    });

    testWidgets('See More opens the category list with descriptions', (
      tester,
    ) async {
      setUpApp();
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('See More').at(1));
      await tester.pumpAndSettle();
      expect(find.byType(SeeMorePage), findsOneWidget);
      expect(find.text('Pop 1'), findsOneWidget);
      expect(find.text('Pop overview 1'), findsOneWidget);
    });

    testWidgets('search and watchlist icons open their pages', (tester) async {
      setUpApp();
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(find.byType(WatchlistPage), findsOneWidget);
    });
  });

  group('Home TV Series tab', () {
    Future<void> openTvTab(WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('TV Series'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows On The Air, Popular and Top Rated series', (
      tester,
    ) async {
      setUpApp();
      await openTvTab(tester);
      expect(find.text('On The Air'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('Top Rated'), findsOneWidget);
    });

    testWidgets('a poster opens the TV detail page', (tester) async {
      setUpApp();
      await openTvTab(tester);
      await tester.tap(find.byType(PosterCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(TvDetailView), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('See More opens the full list with descriptions and detail', (
      tester,
    ) async {
      setUpApp();
      await openTvTab(tester);
      await tester.tap(find.text('See More').at(1));
      await tester.pumpAndSettle();
      expect(find.byType(SeeMorePage), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Popular'), findsOneWidget);
      expect(find.text('TvPop 1'), findsOneWidget);
      expect(find.textContaining('TvPop overview 1'), findsOneWidget);

      await tester.tap(find.text('TvPop 1'));
      await tester.pumpAndSettle();
      expect(find.byType(TvDetailView), findsOneWidget);
    });

    testWidgets('error shows retry and pull to refresh reloads', (
      tester,
    ) async {
      setUpApp(
        routes: {
          '/movie/now_playing': (200, movieList('Now')),
          '/movie/popular': (200, movieList('Pop')),
          '/movie/top_rated': (200, movieList('Top')),
        },
      );
      await openTvTab(tester);
      expect(find.text('not found'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
    });

    testWidgets('pull to refresh reloads the TV sections', (tester) async {
      setUpApp();
      await openTvTab(tester);
      await tester.fling(find.text('On The Air'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('On The Air'), findsOneWidget);
    });
  });

  group('TV See More', () {
    testWidgets('scrolling loads the next page; failure offers retry', (
      tester,
    ) async {
      setUpApp(
        routes: {
          '/tv/popular?page=1': (200, tvList('P1', totalPages: 2)),
          '/tv/popular?page=2': (500, {'status_message': 'Server down'}),
        },
      );
      await tester.pumpWidget(
        app(
          const SeeMorePage(
            title: 'Popular',
            category: MediaCategory.popularTv,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('P1 1'), findsOneWidget);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Server down — tap to retry'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Server down — tap to retry'));
      await tester.pumpAndSettle();
      expect(find.text('Server down — tap to retry'), findsOneWidget);
    });

    testWidgets('pull to refresh reloads the first page', (tester) async {
      setUpApp();
      await tester.pumpWidget(
        app(
          const SeeMorePage(
            title: 'Top Rated',
            category: MediaCategory.topRatedTv,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.fling(find.text('TvTop 1'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('TvTop 1'), findsOneWidget);
    });

    testWidgets('first-page error offers retry; empty list shows a message', (
      tester,
    ) async {
      setUpApp(routes: {});
      await tester.pumpWidget(
        app(
          const SeeMorePage(
            title: 'On The Air',
            category: MediaCategory.onTheAir,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
    });

    testWidgets('empty category shows a message', (tester) async {
      setUpApp(
        routes: {
          '/tv/on_the_air': (200, {'page': 1, 'total_pages': 1, 'results': []}),
        },
      );
      await tester.pumpWidget(
        app(
          const SeeMorePage(
            title: 'On The Air',
            category: MediaCategory.onTheAir,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nothing found'), findsOneWidget);
    });
  });

  group('See More', () {
    testWidgets('scrolling near the bottom loads the next page', (
      tester,
    ) async {
      setUpApp();
      await tester.pumpWidget(
        app(
          const SeeMorePage(
            title: 'Popular',
            category: MediaCategory.popularMovies,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pop 1'), findsOneWidget);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pop 1', skipOffstage: false), findsNWidgets(2));
    });

    testWidgets('a failed next page keeps the list and offers retry', (
      tester,
    ) async {
      setUpApp(
        routes: {
          '/movie/popular?page=1': (200, movieList('Pop', totalPages: 2)),
          '/movie/popular?page=2': (500, {'status_message': 'Server down'}),
        },
      );
      await tester.pumpWidget(
        app(
          const SeeMorePage(
            title: 'Popular',
            category: MediaCategory.popularMovies,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Server down — tap to retry'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pop 1'), findsOneWidget);

      await tester.tap(find.text('Server down — tap to retry'));
      await tester.pumpAndSettle();
      expect(find.text('Server down — tap to retry'), findsOneWidget);
    });

    testWidgets('pull to refresh reloads the first page', (tester) async {
      setUpApp();
      await tester.pumpWidget(
        app(
          const SeeMorePage(
            title: 'Top Rated',
            category: MediaCategory.topRatedMovies,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.fling(find.text('Top 1'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Top 1'), findsOneWidget);
    });

    testWidgets('tapping a movie opens its detail', (tester) async {
      setUpApp();
      await tester.pumpWidget(
        app(
          const SeeMorePage(
            title: 'Top Rated',
            category: MediaCategory.topRatedMovies,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Top 1'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailMovieView), findsOneWidget);
    });

    testWidgets('first-page error shows retry', (tester) async {
      setUpApp(routes: {});
      await tester.pumpWidget(
        app(
          const SeeMorePage(
            title: 'Now Playing',
            category: MediaCategory.nowPlaying,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
    });

    testWidgets('empty category shows a message', (tester) async {
      setUpApp(
        routes: {
          '/movie/now_playing': (
            200,
            {'page': 1, 'total_pages': 1, 'results': []},
          ),
        },
      );
      await tester.pumpWidget(
        app(
          const SeeMorePage(
            title: 'Now Playing',
            category: MediaCategory.nowPlaying,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nothing found'), findsOneWidget);
    });
  });

  group('Search → TV detail → watchlist', () {
    testWidgets('searching from Home opens the TV detail and saves it', (
      tester,
    ) async {
      setUpApp();
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsOneWidget);

      await tester.enterText(find.byType(CustomFormField), 'Dark');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.textContaining('Time travel in Winden.'), findsOneWidget);

      await tester.tap(find.byType(PosterTile));
      await tester.pumpAndSettle();
      expect(find.byType(TvDetailView), findsOneWidget);
      expect(find.text('★ 8.4'), findsOneWidget);
      expect(find.text('Drama · 3 seasons'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('No recommendations.'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(addToWatchlist());
      await tester.pumpAndSettle();
      await expectSnack(tester, 'Added to Watchlist', SnackType.success);
      expect(removeFromWatchlist(), findsOneWidget);
      expect(watchlist.items.single.title, 'Dark');
    });

    testWidgets(
      'a failed watchlist save shows an error snack and keeps the heart empty',
      (tester) async {
        setUpApp(
          store: FakeWatchlistRepository(
            failSave: const DatabaseFailure('disk full'),
          ),
        );
        await tester.pumpWidget(app(const TvDetailView(id: 1)));
        await tester.pumpAndSettle();

        await tester.tap(addToWatchlist());
        await tester.pump();
        await expectSnack(tester, 'disk full', SnackType.error);
        expect(addToWatchlist(), findsOneWidget);
      },
    );

    testWidgets('TV detail lists seasons and a season opens its episodes', (
      tester,
    ) async {
      setUpApp();
      await tester.pumpWidget(app(const TvDetailView(id: 1)));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Season 2'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Seasons'), findsOneWidget);
      expect(find.text('10 episodes · 2017'), findsOneWidget);

      await tester.tap(find.text('Season 1'));
      await tester.pumpAndSettle();
      expect(find.byType(SeasonPage), findsOneWidget);
      expect(find.text('A child goes missing.'), findsOneWidget);
      expect(find.text('E1 · Secrets'), findsOneWidget);
      expect(
        find.textContaining('★ 8.1 · 51 min · 2017-12-01'),
        findsOneWidget,
      );
      expect(find.text('E2 · Lies'), findsOneWidget);
    });

    testWidgets('season page error offers retry', (tester) async {
      setUpApp(routes: {});
      await tester.pumpWidget(
        app(const SeasonPage(tvId: 1, seasonNumber: 1, title: 'Season 1')),
      );
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
    });

    testWidgets('TV detail error offers retry', (tester) async {
      setUpApp(routes: {});
      await tester.pumpWidget(app(const TvDetailView(id: 1)));
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('not found'), findsOneWidget);
    });
  });

  group('Watchlist page', () {
    testWidgets(
      'lists movies and shows; removing a TV series on its detail updates the list',
      (tester) async {
        setUpApp(
          store: FakeWatchlistRepository(initial: [darkItem, inceptionItem]),
        );
        await tester.pumpWidget(app(const WatchlistPage()));
        await tester.pumpAndSettle();
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('Inception'), findsOneWidget);

        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();
        expect(find.byType(TvDetailView), findsOneWidget);
        await tester.tap(removeFromWatchlist());
        await tester.pump();
        await expectSnack(tester, 'Removed from Watchlist', SnackType.success);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Dark'), findsNothing);
        expect(find.text('Inception'), findsOneWidget);
      },
    );

    testWidgets('a movie opens the movie detail page', (tester) async {
      setUpApp(store: FakeWatchlistRepository(initial: [inceptionItem]));
      await tester.pumpWidget(app(const WatchlistPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inception'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailMovieView), findsOneWidget);
      expect(removeFromWatchlist(), findsOneWidget);
    });

    testWidgets('empty watchlist shows a message', (tester) async {
      setUpApp();
      await tester.pumpWidget(app(const WatchlistPage()));
      await tester.pumpAndSettle();
      expect(find.text('Your watchlist is empty'), findsOneWidget);
    });

    testWidgets('storage failure shows the error', (tester) async {
      setUpApp(
        store: FakeWatchlistRepository(
          failGet: const DatabaseFailure('disk error'),
        ),
      );
      await tester.pumpWidget(app(const WatchlistPage()));
      await tester.pumpAndSettle();
      expect(find.text('disk error'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('disk error'), findsOneWidget);
    });
  });

  testWidgets('movie detail: error offers retry', (tester) async {
    setUpApp(routes: {});
    await tester.pumpWidget(app(const DetailMovieView(id: 1)));
    await tester.pumpAndSettle();
    expect(find.text('not found'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('not found'), findsOneWidget);
  });

  testWidgets('movie detail: a recommendation opens on top', (tester) async {
    setUpApp();
    await tester.pumpWidget(app(const DetailMovieView(id: 1)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Recommendations'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PosterCard).at(1));
    await tester.pumpAndSettle();
    expect(find.byType(DetailMovieView, skipOffstage: false), findsNWidgets(2));
  });

  testWidgets('movie detail: watchlist button adds the movie', (tester) async {
    setUpApp();
    await tester.pumpWidget(app(const DetailMovieView(id: 1)));
    await tester.pumpAndSettle();

    await tester.tap(addToWatchlist());
    await tester.pumpAndSettle();
    await expectSnack(tester, 'Added to Watchlist', SnackType.success);
    expect(removeFromWatchlist(), findsOneWidget);
    expect(
      watchlist.items.single,
      const MediaItem(
        id: 1,
        type: MediaType.movie,
        title: 'Inception',
        overview: 'Dreams within dreams.',
        voteAverage: 8.4,
      ),
    );
  });
}
