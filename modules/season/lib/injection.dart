import 'package:get_it/get_it.dart';

import 'data/data.dart';
import 'domain/domain.dart';
import 'presentation/presentation.dart';

void initSeason(GetIt locator) {
  locator
    ..registerLazySingleton(() => SeasonRemoteDataSource(locator()))
    ..registerLazySingleton<SeasonRepository>(
      () => SeasonRepositoryImpl(locator()),
    )
    ..registerLazySingleton(() => GetSeasonDetail(locator()))
    ..registerFactory(() => SeasonBloc(locator()));
}
