part of 'data.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remote;
  SearchRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<SearchResult>>> searchTv(String query) => guard(
    () async =>
        (await remote.searchTv(query)).map((e) => e.toEntity()).toList(),
  );
}
