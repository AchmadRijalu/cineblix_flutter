part of 'data.dart';

class SeeMoreRepositoryImpl implements SeeMoreRepository {
  final SeeMoreRemoteDataSource remote;
  SeeMoreRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, SeeMoreResult>> getItems(
    MediaCategory category,
    int page,
  ) => guard(() => remote.items(category, page));
}
