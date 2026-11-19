part of '../presentation.dart';

class DetailMovieBloc extends Bloc<DetailMovieEvent, DetailMovieState> {
  final GetMovieDetail _getDetail;
  final GetMovieRecommendations _getRecommendations;
  final GetWatchlistStatus _getStatus;
  final SaveWatchlist _save;
  final RemoveWatchlist _remove;

  DetailMovieBloc(
    this._getDetail,
    this._getRecommendations,
    this._getStatus,
    this._save,
    this._remove,
  ) : super(DetailMovieInitial()) {
    on<DetailMovieFetched>(_onFetched);
    on<DetailMovieWatchlistToggled>(_onToggled);
  }

  Future<void> _onFetched(
    DetailMovieFetched event,
    Emitter<DetailMovieState> emit,
  ) async {
    emit(DetailMovieLoading());
    final (detail, recommendations, inWatchlist) = await (
      _getDetail(event.id),
      _getRecommendations(event.id),
      _getStatus(event.id, MediaType.movie),
    ).wait;

    emit(
      detail.match(
        (f) => DetailMovieError(f.message),
        (movie) => DetailMovieLoaded(
          movie,
          recommendations.getOrElse((_) => const []),
          inWatchlist.getOrElse((_) => false),
        ),
      ),
    );
  }

  Future<void> _onToggled(
    DetailMovieWatchlistToggled event,
    Emitter<DetailMovieState> emit,
  ) async {
    final current = state;
    if (current is! DetailMovieLoaded) return;

    final result = current.isAddedToWatchlist
        ? await _remove(current.movie.id, MediaType.movie)
        : await _save(
            MediaItem(
              id: current.movie.id,
              type: MediaType.movie,
              title: current.movie.title,
              overview: current.movie.overview,
              posterPath: current.movie.posterPath,
              voteAverage: current.movie.voteAverage,
            ),
          );
    emit(
      DetailMovieLoaded(
        current.movie,
        current.recommendations,
        result.isRight()
            ? !current.isAddedToWatchlist
            : current.isAddedToWatchlist,
        watchlistMessage: result.match((f) => f.message, (message) => message),
        watchlistFailed: result.isLeft(),
      ),
    );
  }
}
