import 'package:get_it/get_it.dart';

import 'data/data.dart';
import 'domain/domain.dart';
import 'presentation/presentation.dart';

void initHome(GetIt locator) {
  locator
    ..registerLazySingleton(() => HomeRemoteDataSource(locator()))
    ..registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(locator()))
    ..registerLazySingleton(() => GetNowPlayingMovies(locator()))
    ..registerLazySingleton(() => GetPopularMovies(locator()))
    ..registerLazySingleton(() => GetTopRatedMovies(locator()))
    ..registerLazySingleton(() => GetOnTheAirTv(locator()))
    ..registerLazySingleton(() => GetPopularTv(locator()))
    ..registerLazySingleton(() => GetTopRatedTv(locator()))
    ..registerFactory(() => HomeBloc(locator(), locator(), locator()))
    ..registerFactory(() => HomeTvBloc(locator(), locator(), locator()));
}
