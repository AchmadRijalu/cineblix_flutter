part of '../season.dart';

class SeasonBloc extends Bloc<SeasonEvent, SeasonState> {
  final GetSeasonDetail _getSeasonDetail;

  SeasonBloc(this._getSeasonDetail) : super(SeasonInitial()) {
    on<SeasonFetched>(_onFetched);
  }

  Future<void> _onFetched(
    SeasonFetched event,
    Emitter<SeasonState> emit,
  ) async {
    emit(SeasonLoading());
    final result = await _getSeasonDetail(event.tvId, event.seasonNumber);
    emit(result.match((f) => SeasonError(f.message), SeasonLoaded.new));
  }
}
