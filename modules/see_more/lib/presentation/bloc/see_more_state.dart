part of '../presentation.dart';

final class SeeMoreState extends Equatable {
  final RequestState status;
  final List<SeeMoreItem> items;
  final int page;
  final bool hasMore;
  final String message;

  const SeeMoreState({
    this.status = RequestState.idle,
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.message = '',
  });

  SeeMoreState copyWith({
    RequestState? status,
    List<SeeMoreItem>? items,
    int? page,
    bool? hasMore,
    String? message,
  }) => SeeMoreState(
    status: status ?? this.status,
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    message: message ?? this.message,
  );

  @override
  List<Object> get props => [status, items, page, hasMore, message];
}
