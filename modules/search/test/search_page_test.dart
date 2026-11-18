import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search/search.dart';

import 'package:test_support/test_support.dart';

const results = {
  'results': [
    {
      'id': 1,
      'name': 'Dark',
      'overview': 'Time travel in Winden.',
      'poster_path': null,
      'vote_average': 8.4,
    },
    {'id': 2, 'name': 'Dark Matter', 'poster_path': null},
  ],
};

Future<List<int>> openSearch(
  WidgetTester tester,
  Map<String, (int, Object)> routes,
) async {
  GetIt.instance.registerSingleton(fakeDio(routes));
  initSearch(GetIt.instance);
  final tapped = <int>[];
  await tester.pumpWidget(
    MaterialApp(home: SearchPage(onItemTap: (_, id) => tapped.add(id))),
  );
  return tapped;
}

Future<void> submit(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(CustomFormField), query);
  await tester.testTextInput.receiveAction(TextInputAction.search);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(GetIt.instance.reset);

  testWidgets('starts with a prompt and a search field', (tester) async {
    await openSearch(tester, {});
    expect(find.widgetWithText(AppBar, 'Search TV Series'), findsOneWidget);
    expect(find.text('Type a title and press search'), findsOneWidget);
    expect(find.byType(CustomFormField), findsOneWidget);
  });

  testWidgets(
    'submitting a title loads, lists results from the API, and reports taps',
    (tester) async {
      final tapped = await openSearch(tester, {'/search/tv': (200, results)});

      await submit(tester, 'Dark');
      await tester.pump();
      final barrier = find.descendant(
        of: find.byType(CustomLoadingAnimation),
        matching: find.byType(ModalBarrier),
      );
      expect(tester.widget<ModalBarrier>(barrier).color, Colors.transparent);

      await tester.pumpAndSettle();
      expect(find.byType(PosterTile), findsNWidgets(2));
      expect(
        find.descendant(
          of: find.byType(PosterTile),
          matching: find.text('Dark'),
        ),
        findsOneWidget,
      );
      expect(find.text('Dark Matter'), findsOneWidget);
      expect(find.textContaining('★ 8.4'), findsOneWidget);
      expect(find.textContaining('Time travel in Winden.'), findsOneWidget);

      await tester.tap(find.text('Dark Matter'));
      expect(tapped, [2]);
    },
  );

  testWidgets('no results are reported with the query', (tester) async {
    await openSearch(tester, {
      '/search/tv': (200, {'results': []}),
    });
    await submit(tester, 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No TV series found for "zzz"'), findsOneWidget);
  });

  testWidgets('API errors are shown', (tester) async {
    await openSearch(tester, {});
    await submit(tester, 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('not found'), findsOneWidget);
  });
}
