import 'package:get_it/get_it.dart';

import 'data/data.dart';
import 'domain/domain.dart';
import 'presentation/presentation.dart';

void initSearch(GetIt locator) {
  locator
    ..registerLazySingleton(() => SearchRemoteDataSource(locator()))
    ..registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(locator()),
    )
    ..registerLazySingleton(() => SearchTv(locator()))
    ..registerFactory(() => SearchBloc(locator()));
}
