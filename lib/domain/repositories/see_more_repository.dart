part of 'repositories.dart';

abstract class SeeMoreRepository {
  Future<Either<Failure, MediaPage>> getItems(MediaCategory category, int page);
}
