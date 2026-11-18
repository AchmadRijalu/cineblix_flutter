part of '../presentation.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchTv _searchTv;

  SearchBloc(this._searchTv) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged, transformer: restartable());
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) return emit(SearchInitial());

    emit(SearchLoading());
    final result = await _searchTv(query);
    emit(
      result.match(
        (f) => SearchError(f.message),
        (results) =>
            results.isEmpty ? SearchEmpty(query) : SearchLoaded(results),
      ),
    );
  }
}
