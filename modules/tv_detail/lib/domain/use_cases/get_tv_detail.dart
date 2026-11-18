part of '../domain.dart';

class GetTvDetail {
  final TvDetailRepository repository;
  GetTvDetail(this.repository);

  Future<Either<Failure, TvDetail>> call(int id) => repository.getTvDetail(id);
}
