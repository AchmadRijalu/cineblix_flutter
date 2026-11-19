import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:season/season.dart';
import 'package:test_support/test_support.dart';

import 'season_test.dart' show routes;

Future<void> openSeason(
  WidgetTester tester,
  Map<String, (int, Object)> routes,
) async {
  GetIt.instance.registerSingleton(fakeDio(routes));
  initSeason(GetIt.instance);
  await tester.pumpWidget(
    const MaterialApp(
      home: SeasonPage(tvId: 1, seasonNumber: 1, title: 'Season 1'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(GetIt.instance.reset);

  testWidgets('shows the season overview and every episode', (tester) async {
    await openSeason(tester, routes);
    expect(find.widgetWithText(AppBar, 'Season 1'), findsOneWidget);
    expect(find.text('A child goes missing.'), findsOneWidget);
    expect(find.text('E1 · Secrets'), findsOneWidget);
    expect(find.textContaining('★ 8.1 · 51 min · 2017-12-01'), findsOneWidget);
    expect(find.text('E2 · Lies'), findsOneWidget);
    expect(find.textContaining('★ 0.0'), findsOneWidget);
  });

  testWidgets('error offers retry', (tester) async {
    await openSeason(tester, {});
    expect(find.text('not found'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('not found'), findsOneWidget);
  });
}
