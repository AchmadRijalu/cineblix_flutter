import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';

class _FakeDatabaseException extends DatabaseException {
  _FakeDatabaseException() : super('disk full');

  @override
  int? getResultCode() => null;

  @override
  dynamic get result => null;
}

DioException dioError({int? status, Object? data}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    response: status == null
        ? null
        : Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  group('guard', () {
    test('wraps a successful result in Right', () async {
      expect(await guard(() async => 42), const Right<Failure, int>(42));
    });

    test('no response becomes ConnectionFailure', () async {
      expect(
        await guard<int>(() async => throw dioError()),
        const Left<Failure, int>(
          ConnectionFailure('Failed to connect to the network'),
        ),
      );
    });

    test('uses status_message from the TMDB error body', () async {
      expect(
        await guard<int>(
          () async => throw dioError(
            status: 401,
            data: {'status_message': 'Invalid API key'},
          ),
        ),
        const Left<Failure, int>(ServerFailure('Invalid API key')),
      );
    });

    test('falls back to the status code without a status_message', () async {
      expect(
        await guard<int>(() async => throw dioError(status: 500, data: 'oops')),
        const Left<Failure, int>(ServerFailure('Server error (500)')),
      );
    });

    test('a DatabaseException becomes DatabaseFailure', () async {
      final result = await guard<int>(
        () async => throw _FakeDatabaseException(),
      );
      expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
    });
  });

  group('failures', () {
    test('compare by message and keep their type', () {
      expect(const ServerFailure('a'), const ServerFailure('a'));
      expect(const ServerFailure('a'), isNot(const ConnectionFailure('a')));
      expect(const DatabaseFailure('a').message, 'a');
    });
  });

  test('constants and request states', () {
    expect(baseUrl, 'https://api.themoviedb.org/3');
    expect(imageBaseUrl, startsWith('https://image.tmdb.org'));
    expect(apiKey, isA<String>());
    expect(RequestState.values, [
      RequestState.idle,
      RequestState.loading,
      RequestState.success,
      RequestState.failed,
    ]);
  });
}
