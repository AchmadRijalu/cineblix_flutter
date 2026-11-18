part of '../domain.dart';

class GetPopularTv {
  final HomeRepository repository;
  GetPopularTv(this.repository);

  Future<Either<Failure, List<Tv>>> call() => repository.getPopularTv();
}
