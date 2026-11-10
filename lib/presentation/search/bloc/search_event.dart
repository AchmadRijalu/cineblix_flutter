part of '../search.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object> get props => [];
}

final class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object> get props => [query];
}
