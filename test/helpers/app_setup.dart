import 'package:cineblix_flutter/injection.dart';
import 'package:test_support/test_support.dart';
import 'package:watchlist/testing.dart';
import 'package:watchlist/watchlist.dart';

import 'fixtures.dart';

late FakeWatchlistRepository watchlist;

void setUpApp({
  Map<String, (int, Object)>? routes,
  FakeWatchlistRepository? store,
}) {
  watchlist = store ?? FakeWatchlistRepository();
  locator.allowReassignment = true;
  init();
  locator
    ..registerSingleton(fakeDio(routes ?? allRoutes))
    ..registerSingleton<WatchlistRepository>(watchlist);
}
