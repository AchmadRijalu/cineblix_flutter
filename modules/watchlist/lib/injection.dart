import 'package:get_it/get_it.dart';

import 'data/data.dart';
import 'domain/domain.dart';
import 'presentation/presentation.dart';

void initWatchlist(GetIt locator) {
  locator
    ..registerLazySingleton(DatabaseHelper.new)
    ..registerLazySingleton<WatchlistRepository>(
      () => WatchlistRepositoryImpl(locator()),
    )
    ..registerLazySingleton(() => SaveWatchlist(locator()))
    ..registerLazySingleton(() => RemoveWatchlist(locator()))
    ..registerLazySingleton(() => GetWatchlistStatus(locator()))
    ..registerLazySingleton(() => GetWatchlist(locator()))
    ..registerFactory(() => WatchlistBloc(locator()));
}
