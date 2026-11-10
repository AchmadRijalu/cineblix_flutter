part of '../use_cases.dart';

class GetOnTheAirTv {
  final HomeRepository repository;
  GetOnTheAirTv(this.repository);

  Future<Either<Failure, List<Tv>>> call() => repository.getOnTheAirTv();
}
