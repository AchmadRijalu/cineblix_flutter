part of '../use_cases.dart';

class SearchTv {
  final SearchRepository repository;
  SearchTv(this.repository);

  Future<Either<Failure, List<Tv>>> call(String query) =>
      repository.searchTv(query);
}
