import 'package:get_it/get_it.dart';
import 'package:search/search.dart';
import 'data/data_sources/data_sources.dart';
import 'data/repositories/repositories.dart';
import 'domain/entities/entities.dart';
import 'domain/repositories/repositories.dart';
import 'domain/use_cases/use_cases.dart';
import 'presentation/detail_movie/detail_movie.dart';
import 'presentation/favorites/favorites.dart';
import 'presentation/home/home.dart';
import 'presentation/season/season.dart';
import 'presentation/see_more/see_more.dart';
import 'presentation/tv_detail/tv_detail.dart';

final locator = GetIt.instance;

void init() {
  _initCore();
  _initHome();
  _initDetailMovie();
  _initSeeMore();
  _initTvDetail();
  _initSeason();
  initSearch(locator);
  _initWatchlist();
}

void _initCore() {
  locator
    ..registerLazySingleton(createDio)
    ..registerLazySingleton(DatabaseHelper.new);
}

void _initHome() {
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

void _initDetailMovie() {
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

void _initSeeMore() {
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

void _initTvDetail() {
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

void _initSeason() {
  locator
    ..registerLazySingleton(() => SeasonRemoteDataSource(locator()))
    ..registerLazySingleton<SeasonRepository>(
      () => SeasonRepositoryImpl(locator()),
    )
    ..registerLazySingleton(() => GetSeasonDetail(locator()))
    ..registerFactory(() => SeasonBloc(locator()));
}

void _initWatchlist() {
  locator
    ..registerLazySingleton<WatchlistRepository>(
      () => WatchlistRepositoryImpl(locator()),
    )
    ..registerLazySingleton(() => SaveWatchlist(locator()))
    ..registerLazySingleton(() => RemoveWatchlist(locator()))
    ..registerLazySingleton(() => GetWatchlistStatus(locator()))
    ..registerLazySingleton(() => GetWatchlist(locator()))
    ..registerFactory(() => WatchlistBloc(locator()));
}
