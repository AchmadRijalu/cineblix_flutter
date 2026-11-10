part of 'repositories.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Tv>>> searchTv(String query);
}
