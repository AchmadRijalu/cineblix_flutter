import 'package:get_it/get_it.dart';

import 'data/data.dart';
import 'domain/domain.dart';
import 'presentation/presentation.dart';

void initDetailMovie(GetIt locator) {
  locator
    ..registerLazySingleton(() => DetailMovieRemoteDataSource(locator()))
    ..registerLazySingleton<DetailMovieRepository>(
      () => DetailMovieRepositoryImpl(locator()),
    )
    ..registerLazySingleton(() => GetMovieDetail(locator()))
    ..registerLazySingleton(() => GetMovieRecommendations(locator()))
    ..registerFactory(
      () => DetailMovieBloc(
        locator(),
        locator(),
        locator(),
        locator(),
        locator(),
      ),
    );
}
