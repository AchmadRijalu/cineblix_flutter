import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

import 'data/data.dart';
import 'domain/domain.dart';
import 'presentation/presentation.dart';

void initSeeMore(GetIt locator) {
  locator
    ..registerLazySingleton(() => SeeMoreRemoteDataSource(locator()))
    ..registerLazySingleton<SeeMoreRepository>(
      () => SeeMoreRepositoryImpl(locator()),
    )
    ..registerLazySingleton(() => GetSeeMoreItems(locator()))
    ..registerFactoryParam<SeeMoreBloc, MediaCategory, void>(
      (category, _) => SeeMoreBloc(locator(), category),
    );
}
