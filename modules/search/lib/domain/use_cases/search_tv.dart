part of '../domain.dart';

class SearchTv {
  final SearchRepository repository;
  SearchTv(this.repository);

  Future<Either<Failure, List<SearchResult>>> call(String query) =>
      repository.searchTv(query);
}
