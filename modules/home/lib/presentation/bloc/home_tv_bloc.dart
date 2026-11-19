part of '../presentation.dart';

class HomeTvBloc extends Bloc<HomeTvEvent, HomeTvState> {
  final GetOnTheAirTv _getOnTheAir;
  final GetPopularTv _getPopular;
  final GetTopRatedTv _getTopRated;

  HomeTvBloc(this._getOnTheAir, this._getPopular, this._getTopRated)
    : super(HomeTvInitial()) {
    on<HomeTvFetched>(_onFetched);
  }

  Future<void> _onFetched(
    HomeTvFetched event,
    Emitter<HomeTvState> emit,
  ) async {
    emit(HomeTvLoading());
    final (onTheAir, popular, topRated) = await (
      _getOnTheAir(),
      _getPopular(),
      _getTopRated(),
    ).wait;

    final result = onTheAir.flatMap(
      (a) => popular.flatMap(
        (p) => topRated.map(
          (t) => HomeTvLoaded(onTheAir: a, popular: p, topRated: t),
        ),
      ),
    );
    emit(result.match((f) => HomeTvError(f.message), (loaded) => loaded));
  }
}
