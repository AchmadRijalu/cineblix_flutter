part of '../domain.dart';

class SeeMoreResult extends Equatable {
  final List<SeeMoreItem> items;
  final int page;
  final int totalPages;

  const SeeMoreResult({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;

  @override
  List<Object> get props => [items, page, totalPages];
}
