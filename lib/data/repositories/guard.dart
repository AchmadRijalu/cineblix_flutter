part of 'repositories.dart';

Future<Either<Failure, T>> guard<T>(Future<T> Function() call) async {
  try {
    return Right(await call());
  } on DioException catch (e) {
    final response = e.response;
    if (response == null) {
      return const Left(ConnectionFailure('Failed to connect to the network'));
    }
    final data = response.data;
    final message = data is Map && data['status_message'] is String
        ? data['status_message'] as String
        : 'Server error (${response.statusCode})';
    return Left(ServerFailure(message));
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(e.toString()));
  }
}
