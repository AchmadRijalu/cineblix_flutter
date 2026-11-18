import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:search/data/data.dart';
import 'package:search/domain/domain.dart';

import 'package:test_support/test_support.dart';

const dark = SearchResult(
  id: 1,
  name: 'Dark',
  overview: 'Time travel in Winden.',
  posterPath: '/p.jpg',
  voteAverage: 8.4,
);

const darkJson = {
  'id': 1,
  'name': 'Dark',
  'overview': 'Time travel in Winden.',
  'poster_path': '/p.jpg',
  'vote_average': 8.4,
};

void main() {
  group('SearchResultModel', () {
    test('maps every field', () {
      expect(SearchResultModel.fromJson(darkJson).toEntity(), dark);
    });

    test('tolerates missing optional fields and an int vote_average', () {
      expect(
        SearchResultModel.fromJson({
          'id': 2,
          'name': null,
          'vote_average': 8,
        }).toEntity(),
        const SearchResult(id: 2, name: '', voteAverage: 8),
      );
    });

    test('listFromJson reads results', () {
      expect(
        SearchResultModel.listFromJson({
          'results': [darkJson],
        }).single.toEntity(),
        dark,
      );
    });
  });

  group('SearchRemoteDataSource', () {
    test('sends the raw query to /search/tv, URL-encoded', () async {
      final log = <RequestOptions>[];
      final ds = SearchRemoteDataSource(
        fakeDio({
          '/search/tv': (
            200,
            {
              'results': [
                {'id': 1, 'name': 'Tom & Jerry'},
              ],
            },
          ),
        }, log: log),
      );
      expect((await ds.searchTv('Tom & Jerry')).single.name, 'Tom & Jerry');
      expect(log.single.path, '/search/tv');
      expect(log.single.uri.queryParameters['query'], 'Tom & Jerry');
      expect(log.single.uri.query, contains('query=Tom+%26+Jerry'));
    });
  });

  group('SearchRepositoryImpl', () {
    test('maps results to entities through the use case', () async {
      final repo = SearchRepositoryImpl(
        SearchRemoteDataSource(
          fakeDio({
            '/search/tv': (
              200,
              {
                'results': [darkJson],
              },
            ),
          }),
        ),
      );
      expect((await SearchTv(repo)('dark')).getOrElse((_) => []), [dark]);
    });

    test('an HTTP error becomes a ServerFailure', () async {
      final repo = SearchRepositoryImpl(SearchRemoteDataSource(fakeDio({})));
      expect(
        await repo.searchTv('x'),
        const Left<Failure, List<SearchResult>>(ServerFailure('not found')),
      );
    });

    test('no network becomes a ConnectionFailure', () async {
      final repo = SearchRepositoryImpl(
        SearchRemoteDataSource(
          fakeDio({'/search/tv': (0, <String, Object>{})}),
        ),
      );
      expect(
        await repo.searchTv('x'),
        const Left<Failure, List<SearchResult>>(
          ConnectionFailure('Failed to connect to the network'),
        ),
      );
    });
  });
}
