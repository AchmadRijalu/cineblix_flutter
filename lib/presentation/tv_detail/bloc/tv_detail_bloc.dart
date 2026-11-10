part of '../tv_detail.dart';

class TvDetailBloc extends Bloc<TvDetailEvent, TvDetailState> {
  final GetTvDetail _getDetail;
  final GetTvRecommendations _getRecommendations;
  final GetWatchlistStatus _getStatus;
  final SaveWatchlist _save;
  final RemoveWatchlist _remove;

  TvDetailBloc(
    this._getDetail,
    this._getRecommendations,
    this._getStatus,
    this._save,
    this._remove,
  ) : super(TvDetailInitial()) {
    on<TvDetailFetched>(_onFetched);
    on<TvDetailWatchlistToggled>(_onToggled);
  }

  Future<void> _onFetched(
    TvDetailFetched event,
    Emitter<TvDetailState> emit,
  ) async {
    emit(TvDetailLoading());
    final (detail, recommendations, inWatchlist) = await (
      _getDetail(event.id),
      _getRecommendations(event.id),
      _getStatus(event.id, MediaType.tv),
    ).wait;

    emit(
      detail.match(
        (f) => TvDetailError(f.message),
        (tv) => TvDetailLoaded(
          tv,
          recommendations.getOrElse((_) => const []),
          inWatchlist.getOrElse((_) => false),
        ),
      ),
    );
  }

  Future<void> _onToggled(
    TvDetailWatchlistToggled event,
    Emitter<TvDetailState> emit,
  ) async {
    final current = state;
    if (current is! TvDetailLoaded) return;

    final result = current.isAddedToWatchlist
        ? await _remove(current.tv.id, MediaType.tv)
        : await _save(MediaItem.fromTv(current.tv));
    emit(
      TvDetailLoaded(
        current.tv,
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
