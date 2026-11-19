import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:search/domain/domain.dart';
import 'package:search/presentation/presentation.dart';

const a = SearchResult(id: 1, name: 'A');
const ab = SearchResult(id: 2, name: 'AB');

class FakeSearchRepository implements SearchRepository {
  final Map<String, (Duration, Either<Failure, List<SearchResult>>)> answers;
  final calls = <String>[];
  FakeSearchRepository(this.answers);

  @override
  Future<Either<Failure, List<SearchResult>>> searchTv(String query) async {
    calls.add(query);
    final (delay, result) =
        answers[query] ??
        (Duration.zero, const Right<Failure, List<SearchResult>>([]));
    await Future<void>.delayed(delay);
    return result;
  }
}

SearchBloc build(FakeSearchRepository repo) => SearchBloc(SearchTv(repo));

void main() {
  test('blank query returns to Initial without calling the API', () async {
    final repo = FakeSearchRepository({
      'dark': (Duration.zero, const Right([a])),
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
        'dark': (Duration.zero, const Right([a])),
      }),
    );
    bloc.add(const SearchQueryChanged('dark'));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        SearchLoading(),
        const SearchLoaded([a]),
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
        'a': (const Duration(milliseconds: 50), const Right([a])),
        'ab': (Duration.zero, const Right([ab])),
      }),
    );
    bloc.add(const SearchQueryChanged('a'));
    bloc.add(const SearchQueryChanged('ab'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(bloc.state, const SearchLoaded([ab]));
  });

  test('events compare by query', () {
    expect(const SearchQueryChanged('a'), const SearchQueryChanged('a'));
    expect(const SearchQueryChanged('a'), isNot(const SearchQueryChanged('b')));
  });
}
