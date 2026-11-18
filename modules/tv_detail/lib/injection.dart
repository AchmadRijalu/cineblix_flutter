import 'package:get_it/get_it.dart';

import 'data/data.dart';
import 'domain/domain.dart';
import 'presentation/presentation.dart';

void initTvDetail(GetIt locator) {
  locator
    ..registerLazySingleton(() => TvDetailRemoteDataSource(locator()))
    ..registerLazySingleton<TvDetailRepository>(
      () => TvDetailRepositoryImpl(locator()),
    )
    ..registerLazySingleton(() => GetTvDetail(locator()))
    ..registerLazySingleton(() => GetTvRecommendations(locator()))
    ..registerFactory(
      () => TvDetailBloc(locator(), locator(), locator(), locator(), locator()),
    );
}
