import 'package:cineblix_flutter/common/commons.dart';
import 'package:cineblix_flutter/data/data_sources/data_sources.dart';
import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:cineblix_flutter/domain/repositories/repositories.dart';
import 'package:cineblix_flutter/domain/use_cases/use_cases.dart';
import 'package:cineblix_flutter/presentation/search/search.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'helpers/fake_dio.dart';

const tvA = Tv(id: 1, name: 'A');
const tvAB = Tv(id: 2, name: 'AB');

class FakeSearchRepository implements SearchRepository {
  final Map<String, (Duration, Either<Failure, List<Tv>>)> answers;
  final calls = <String>[];
  FakeSearchRepository(this.answers);

  @override
  Future<Either<Failure, List<Tv>>> searchTv(String query) async {
    calls.add(query);
    final (delay, result) =
        answers[query] ?? (Duration.zero, const Right<Failure, List<Tv>>([]));
    await Future<void>.delayed(delay);
    return result;
  }
}

SearchBloc build(FakeSearchRepository repo) => SearchBloc(SearchTv(repo));

void main() {
  test('searchTv sends the raw query to /search/tv, URL-encoded', () async {
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

  test('blank query returns to Initial without calling the API', () async {
    final repo = FakeSearchRepository({
      'dark': (Duration.zero, const Right([tvA])),
    });
    final bloc = build(repo);
    bloc.add(const SearchQueryChanged('dark'));
    await bloc.stream.firstWhere((s) => s is SearchLoaded);

    bloc.add(const SearchQueryChanged('   '));
    expect(await bloc.stream.first, SearchInitial());
    expect(repo.calls, ['dark']);
  });

  test('query is trimmed before calling the API', () async {
    final repo = FakeSearchRepository({});
    final bloc = build(repo);
    bloc.add(const SearchQueryChanged('  dark '));
    await bloc.stream.firstWhere((s) => s is! SearchLoading);
    expect(repo.calls, ['dark']);
  });

  test('results emit Loading then Loaded', () async {
    final bloc = build(
      FakeSearchRepository({
        'dark': (Duration.zero, const Right([tvA])),
      }),
    );
    bloc.add(const SearchQueryChanged('dark'));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        SearchLoading(),
        const SearchLoaded([tvA]),
      ]),
    );
  });

  test('no results emit SearchEmpty(query)', () async {
    final bloc = build(FakeSearchRepository({}));
    bloc.add(const SearchQueryChanged('zzz'));
    await expectLater(
      bloc.stream,
      emitsInOrder([SearchLoading(), const SearchEmpty('zzz')]),
    );
  });

  test('API failure emits SearchError', () async {
    final bloc = build(
      FakeSearchRepository({
        'dark': (Duration.zero, const Left(ServerFailure('Invalid API key'))),
      }),
    );
    bloc.add(const SearchQueryChanged('dark'));
    await expectLater(
      bloc.stream,
      emitsInOrder([SearchLoading(), const SearchError('Invalid API key')]),
    );
  });

  test('a slower earlier query cannot overwrite a newer one', () async {
    final bloc = build(
      FakeSearchRepository({
        'a': (const Duration(milliseconds: 50), const Right([tvA])),
        'ab': (Duration.zero, const Right([tvAB])),
      }),
    );
    bloc.add(const SearchQueryChanged('a'));
    bloc.add(const SearchQueryChanged('ab'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(bloc.state, const SearchLoaded([tvAB]));
  });
}
