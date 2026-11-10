part of '../use_cases.dart';

class GetTopRatedTv {
  final HomeRepository repository;
  GetTopRatedTv(this.repository);

  Future<Either<Failure, List<Tv>>> call() => repository.getTopRatedTv();
}
