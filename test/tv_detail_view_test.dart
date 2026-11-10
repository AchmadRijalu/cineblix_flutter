import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:cineblix_flutter/domain/use_cases/use_cases.dart';
import 'package:cineblix_flutter/injection.dart';
import 'package:cineblix_flutter/presentation/tv_detail/tv_detail.dart';
import 'package:cineblix_flutter/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'helpers/fakes.dart';

const noPoster = TvDetail(
  id: 1,
  name: 'Dark',
  overview: 'x',
  posterPath: null,
  voteAverage: 8.4,
  genres: [],
  numberOfSeasons: 3,
  firstAirDate: '',
);

void main() {
  setUp(() {
    final t = FakeTvDetailRepository(detail: const Right(noPoster));
    final w = FakeWatchlistRepository();
    locator.registerFactory(
      () => TvDetailBloc(
        GetTvDetail(t),
        GetTvRecommendations(t),
        GetWatchlistStatus(w),
        SaveWatchlist(w),
        RemoveWatchlist(w),
      ),
    );
  });
  tearDown(locator.reset);

  testWidgets(
    'tapping a recommendation pushes a new detail page on top (back returns)',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TvDetailView(id: 1)));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Recommendations'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(
        find.byType(PosterCard),
        findsNWidgets(2),
        reason: 'main poster + one recommendation',
      );
      await tester.tap(find.byType(PosterCard).last);
      await tester.pumpAndSettle();

      expect(find.byType(TvDetailView, skipOffstage: false), findsNWidgets(2));
    },
  );
}
