part of '../domain.dart';

class GetSeeMoreItems {
  final SeeMoreRepository repository;
  GetSeeMoreItems(this.repository);

  Future<Either<Failure, SeeMoreResult>> call(
    MediaCategory category,
    int page,
  ) => repository.getItems(category, page);
}
