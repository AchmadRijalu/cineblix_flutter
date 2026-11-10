import 'package:cineblix_flutter/domain/repositories/repositories.dart';
import 'package:cineblix_flutter/injection.dart';
import 'package:dio/dio.dart';

import 'fake_dio.dart';
import 'fakes.dart';
import 'tmdb_fixtures.dart';

late FakeWatchlistRepository watchlist;

void setUpApp({
  Map<String, (int, Object)>? routes,
  FakeWatchlistRepository? store,
}) {
  watchlist = store ?? FakeWatchlistRepository();
  locator.allowReassignment = true;
  init();
  locator
    ..registerLazySingleton<Dio>(() => fakeDio(routes ?? allRoutes))
    ..registerLazySingleton<WatchlistRepository>(() => watchlist);
}
