part of '../use_cases.dart';

class GetPopularTv {
  final HomeRepository repository;
  GetPopularTv(this.repository);

  Future<Either<Failure, List<Tv>>> call() => repository.getPopularTv();
}
