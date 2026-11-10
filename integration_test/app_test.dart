import 'package:cineblix_flutter/injection.dart';
import 'package:cineblix_flutter/main.dart';
import 'package:cineblix_flutter/presentation/detail_movie/detail_movie.dart';
import 'package:cineblix_flutter/presentation/favorites/favorites.dart';
import 'package:cineblix_flutter/presentation/search/search.dart';
import 'package:cineblix_flutter/presentation/season/season.dart';
import 'package:cineblix_flutter/presentation/tv_detail/tv_detail.dart';
import 'package:cineblix_flutter/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/app_setup.dart';

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
  expect(finder, findsWidgets);
}

Future<void> settleSnack(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(locator.reset);

  testWidgets('home, movie detail and watchlist', (tester) async {
    setUpApp();
    await tester.pumpWidget(const MyApp());
    await waitFor(tester, find.text('Now Playing'));
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);

    await tester.tap(find.byType(PosterCard).first);
    await waitFor(tester, find.text('Inception'));
    expect(find.byType(DetailMovieView), findsOneWidget);

    await tester.tap(find.byTooltip('Add to Watchlist'));
    await tester.pump();
    expect(find.text('Added to Watchlist'), findsOneWidget);
    await settleSnack(tester);
    expect(find.byTooltip('Remove from Watchlist'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite));
    await waitFor(tester, find.byType(WatchlistPage));
    await waitFor(tester, find.text('Inception'));
  });

  testWidgets('search a TV series, open a season and save it', (tester) async {
    setUpApp();
    await tester.pumpWidget(const MyApp());
    await waitFor(tester, find.text('Now Playing'));

    await tester.tap(find.byIcon(Icons.search));
    await waitFor(tester, find.byType(SearchPage));
    await tester.enterText(find.byType(CustomFormField), 'Dark');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await waitFor(tester, find.byType(PosterTile));

    await tester.tap(find.byType(PosterTile));
    await waitFor(tester, find.byType(TvDetailView));
    await waitFor(tester, find.text('★ 8.4'));
    expect(find.text('Time travel in Winden.'), findsOneWidget);

    await tester.tap(find.byTooltip('Add to Watchlist'));
    await tester.pump();
    expect(find.text('Added to Watchlist'), findsOneWidget);
    await settleSnack(tester);
    expect(watchlist.items.single.title, 'Dark');

    await tester.scrollUntilVisible(
      find.text('Season 1'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Season 1'));
    await waitFor(tester, find.byType(SeasonPage));
    await waitFor(tester, find.text('E1 · Secrets'));
    expect(find.text('E2 · Lies'), findsOneWidget);
  });

  testWidgets('TV Series tab lists series and opens a detail', (tester) async {
    setUpApp();
    await tester.pumpWidget(const MyApp());
    await waitFor(tester, find.text('Now Playing'));

    await tester.tap(find.text('TV Series'));
    await waitFor(tester, find.text('On The Air'));

    await tester.tap(find.byType(PosterCard).first);
    await waitFor(tester, find.byType(TvDetailView));
    await waitFor(tester, find.text('Seasons'));
  });
}
