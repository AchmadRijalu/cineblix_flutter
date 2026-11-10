part of '../see_more.dart';

class SeeMoreBloc extends Bloc<SeeMoreEvent, SeeMoreState> {
  final GetSeeMoreItems _getItems;
  final MediaCategory category;

  SeeMoreBloc(this._getItems, this.category) : super(const SeeMoreState()) {
    on<SeeMoreFetched>(_onFetched);
    on<SeeMoreNextPageRequested>(_onNextPage);
  }

  Future<void> _onFetched(
    SeeMoreFetched event,
    Emitter<SeeMoreState> emit,
  ) async {
    emit(const SeeMoreState(status: RequestState.loading));
    final result = await _getItems(category, 1);
    emit(
      result.match(
        (f) => SeeMoreState(status: RequestState.failed, message: f.message),
        (p) => SeeMoreState(
          status: RequestState.success,
          items: p.items,
          page: p.page,
          hasMore: p.hasMore,
        ),
      ),
    );
  }

  Future<void> _onNextPage(
    SeeMoreNextPageRequested event,
    Emitter<SeeMoreState> emit,
  ) async {
    if (state.status == RequestState.loading || !state.hasMore) return;
    emit(state.copyWith(status: RequestState.loading));
    final result = await _getItems(category, state.page + 1);
    emit(
      result.match(
        (f) => state.copyWith(status: RequestState.failed, message: f.message),
        (p) => state.copyWith(
          status: RequestState.success,
          items: [...state.items, ...p.items],
          page: p.page,
          hasMore: p.hasMore,
        ),
      ),
    );
  }
}
