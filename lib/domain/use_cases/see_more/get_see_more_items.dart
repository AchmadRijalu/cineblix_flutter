part of '../use_cases.dart';

class GetSeeMoreItems {
  final SeeMoreRepository repository;
  GetSeeMoreItems(this.repository);

  Future<Either<Failure, MediaPage>> call(MediaCategory category, int page) =>
      repository.getItems(category, page);
}
