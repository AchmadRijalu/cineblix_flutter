part of '../presentation.dart';

sealed class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object> get props => [];
}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchLoaded extends SearchState {
  final List<SearchResult> results;
  const SearchLoaded(this.results);
  @override
  List<Object> get props => [results];
}

final class SearchEmpty extends SearchState {
  final String query;
  const SearchEmpty(this.query);
  @override
  List<Object> get props => [query];
}

final class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object> get props => [message];
}
