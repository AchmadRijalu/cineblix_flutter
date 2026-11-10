part of 'repositories.dart';

class SeeMoreRepositoryImpl implements SeeMoreRepository {
  final SeeMoreRemoteDataSource remote;
  SeeMoreRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, MediaPage>> getItems(
    MediaCategory category,
    int page,
  ) => guard(() => remote.items(category, page));
}
