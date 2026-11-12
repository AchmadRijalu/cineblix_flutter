import 'package:cineblix_flutter/data/data_sources/data_sources.dart';
import 'package:cineblix_flutter/data/repositories/repositories.dart';
import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'helpers/fake_dio.dart';

void main() {
  test('getTvDetail calls /tv/{id} and maps to entity', () async {
    final log = <RequestOptions>[];
    final repo = TvDetailRepositoryImpl(
      TvDetailRemoteDataSource(
        fakeDio({
          '/tv/1': (200, {'id': 1, 'name': 'Dark'}),
        }, log: log),
      ),
    );
    expect(
      (await repo.getTvDetail(1)).getOrElse((_) => throw 'fail').name,
      'Dark',
    );
    expect(log.single.path, '/tv/1');
  });

  test('getTvRecommendations calls /tv/{id}/recommendations', () async {
    final repo = TvDetailRepositoryImpl(
      TvDetailRemoteDataSource(
        fakeDio({
          '/tv/1/recommendations': (
            200,
            {
              'results': [
                {'id': 2, 'name': '1899'},
              ],
            },
          ),
        }),
      ),
    );
    expect((await repo.getTvRecommendations(1)).getOrElse((_) => []), [
      const Tv(id: 2, name: '1899'),
    ]);
  });

  test(
    'HTTP error becomes ServerFailure carrying TMDB status_message',
    () async {
      final repo = TvDetailRepositoryImpl(
        TvDetailRemoteDataSource(fakeDio({})),
      );
      expect(
        await repo.getTvDetail(99),
        const Left<Failure, TvDetail>(ServerFailure('not found')),
      );
    },
  );
}
