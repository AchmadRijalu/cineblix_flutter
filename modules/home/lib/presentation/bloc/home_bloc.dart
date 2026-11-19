part of '../presentation.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetNowPlayingMovies _getNowPlaying;
  final GetPopularMovies _getPopular;
  final GetTopRatedMovies _getTopRated;

  HomeBloc(this._getNowPlaying, this._getPopular, this._getTopRated)
    : super(HomeInitial()) {
    on<HomeFetched>(_onFetched);
  }

  Future<void> _onFetched(HomeFetched event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final (nowPlaying, popular, topRated) = await (
      _getNowPlaying(),
      _getPopular(),
      _getTopRated(),
    ).wait;

    final result = nowPlaying.flatMap(
      (n) => popular.flatMap(
        (p) => topRated.map(
          (t) => HomeLoaded(nowPlaying: n, popular: p, topRated: t),
        ),
      ),
    );

    emit(result.match((f) => HomeError(f.message), (loaded) => loaded));
  }
}
