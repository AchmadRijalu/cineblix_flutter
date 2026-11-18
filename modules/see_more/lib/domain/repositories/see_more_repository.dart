part of '../domain.dart';

abstract class SeeMoreRepository {
  Future<Either<Failure, SeeMoreResult>> getItems(
    MediaCategory category,
    int page,
  );
}
