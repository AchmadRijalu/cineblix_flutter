import 'package:about/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the app name, description and TMDB credit', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));

    expect(find.widgetWithText(AppBar, 'About'), findsOneWidget);
    expect(find.text('Cineblix'), findsOneWidget);
    expect(find.textContaining('movies and TV series'), findsOneWidget);
    expect(find.textContaining('The Movie Database (TMDB)'), findsOneWidget);
  });
}
