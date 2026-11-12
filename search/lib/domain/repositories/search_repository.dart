part of '../domain.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchResult>>> searchTv(String query);
}
