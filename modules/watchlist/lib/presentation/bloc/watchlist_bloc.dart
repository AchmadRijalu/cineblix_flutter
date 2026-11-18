part of '../presentation.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlist _getWatchlist;

  WatchlistBloc(this._getWatchlist) : super(WatchlistInitial()) {
    on<WatchlistFetched>(_onFetched);
  }

  Future<void> _onFetched(
    WatchlistFetched event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(WatchlistLoading());
    final result = await _getWatchlist();
    emit(result.match((f) => WatchlistError(f.message), WatchlistLoaded.new));
  }
}
