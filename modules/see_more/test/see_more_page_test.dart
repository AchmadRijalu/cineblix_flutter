import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:see_more/see_more.dart';
import 'package:test_support/test_support.dart';

import 'see_more_data_test.dart' show list, routes;

Future<List<(MediaType, int)>> openSeeMore(
  WidgetTester tester,
  Map<String, (int, Object)> routes, {
  MediaCategory category = MediaCategory.popularMovies,
  String title = 'Popular',
}) async {
  GetIt.instance.registerSingleton(fakeDio(routes));
  initSeeMore(GetIt.instance);
  final tapped = <(MediaType, int)>[];
  await tester.pumpWidget(
    MaterialApp(
      home: SeeMorePage(
        title: title,
        category: category,
        onItemTap: (_, type, id) => tapped.add((type, id)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tapped;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(GetIt.instance.reset);

  testWidgets('shows the title, items with descriptions, and reports taps', (
    tester,
  ) async {
    final tapped = await openSeeMore(tester, routes);
    expect(find.widgetWithText(AppBar, 'Popular'), findsOneWidget);
    expect(find.text('Pop 1'), findsOneWidget);
    expect(find.text('Pop overview 1'), findsOneWidget);

    await tester.tap(find.text('Pop 2'));
    expect(tapped, [(MediaType.movie, 2)]);
  });

  testWidgets('a TV category reports TV taps', (tester) async {
    final tapped = await openSeeMore(
      tester,
      routes,
      category: MediaCategory.topRatedTv,
      title: 'Top Rated',
    );
    await tester.tap(find.text('TvTop 1'));
    expect(tapped, [(MediaType.tv, 1)]);
  });

  testWidgets('an item without a description says so', (tester) async {
    await openSeeMore(tester, {
      '/movie/popular': (
        200,
        {
          'page': 1,
          'total_pages': 1,
          'results': [
            {'id': 1, 'title': 'Silent', 'poster_path': null},
          ],
        },
      ),
    });
    expect(find.text('No description.'), findsOneWidget);
  });

  testWidgets('scrolling near the bottom loads the next page', (tester) async {
    await openSeeMore(tester, {
      '/movie/popular?page=1': (
        200,
        list('title', prefix: 'P1', totalPages: 2),
      ),
      '/movie/popular?page=2': (
        200,
        list('title', prefix: 'P2', page: 2, totalPages: 2),
      ),
    });
    expect(find.text('P1 1'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text('P2 1', skipOffstage: false), findsOneWidget);
  });

  testWidgets('a failed next page keeps the list and offers retry', (
    tester,
  ) async {
    await openSeeMore(tester, {
      '/movie/popular?page=1': (
        200,
        list('title', prefix: 'P1', totalPages: 2),
      ),
      '/movie/popular?page=2': (500, {'status_message': 'Server down'}),
    });

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
    expect(find.text('P1 1'), findsOneWidget);

    await tester.tap(find.text('Server down — tap to retry'));
    await tester.pumpAndSettle();
    expect(find.text('Server down — tap to retry'), findsOneWidget);
  });

  testWidgets('pull to refresh reloads the first page', (tester) async {
    await openSeeMore(tester, routes);
    await tester.fling(find.text('Pop 1'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Pop 1'), findsOneWidget);
  });

  testWidgets('a first-page error offers retry', (tester) async {
    await openSeeMore(tester, {});
    expect(find.text('not found'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('not found'), findsOneWidget);
  });

  testWidgets('an empty category shows a message', (tester) async {
    await openSeeMore(tester, {
      '/movie/popular': (
        200,
        {'page': 1, 'total_pages': 1, 'results': <Object>[]},
      ),
    });
    expect(find.text('Nothing found'), findsOneWidget);
  });
}
