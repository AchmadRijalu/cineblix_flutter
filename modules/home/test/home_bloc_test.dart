import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:home/data/data.dart';
import 'package:home/domain/domain.dart';
import 'package:home/presentation/presentation.dart';
import 'package:test_support/test_support.dart';

Map<String, dynamic> movieList(String prefix) => {
  'results': [
    for (var i = 1; i <= 3; i++)
      {
        'id': i,
        'title': '$prefix $i',
        'overview': '$prefix overview $i',
        'poster_path': null,
      },
  ],
};

Map<String, dynamic> tvList(String prefix) => {
  'results': [
    for (var i = 1; i <= 3; i++)
      {
        'id': i,
        'name': '$prefix $i',
        'overview': '$prefix overview $i',
        'poster_path': null,
        'vote_average': 7.5,
      },
  ],
};

final routes = <String, (int, Object)>{
  '/movie/now_playing': (200, movieList('Now')),
  '/movie/popular': (200, movieList('Pop')),
  '/movie/top_rated': (200, movieList('Top')),
  '/tv/on_the_air': (200, tvList('Air')),
  '/tv/popular': (200, tvList('TvPop')),
  '/tv/top_rated': (200, tvList('TvTop')),
};

const movie = Movie(id: 1, title: 'A');

HomeRepository repo(
  Map<String, (int, Object)> routes, {
  List<RequestOptions>? log,
}) => HomeRepositoryImpl(HomeRemoteDataSource(fakeDio(routes, log: log)));

class FakeHomeRepository implements HomeRepository {
  final Either<Failure, List<Movie>> popular;
  FakeHomeRepository(this.popular);

  @override
  Future<Either<Failure, List<Movie>>> getNowPlayingMovies() async =>
      const Right([movie]);
  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies() async => popular;
  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies() async =>
      const Right([movie]);
  @override
  Future<Either<Failure, List<Tv>>> getOnTheAirTv() async => const Right([]);
  @override
  Future<Either<Failure, List<Tv>>> getPopularTv() async => const Right([]);
  @override
  Future<Either<Failure, List<Tv>>> getTopRatedTv() async => const Right([]);
}

HomeBloc build(Either<Failure, List<Movie>> popular) {
  final repo = FakeHomeRepository(popular);
  return HomeBloc(
    GetNowPlayingMovies(repo),
    GetPopularMovies(repo),
    GetTopRatedMovies(repo),
  );
}

HomeTvBloc buildTv(HomeRepository repo) =>
    HomeTvBloc(GetOnTheAirTv(repo), GetPopularTv(repo), GetTopRatedTv(repo));

void main() {
  group('repository', () {
    test('movie lists map results and call their endpoints', () async {
      final log = <RequestOptions>[];
      final r = repo(routes, log: log);
      expect(
        (await GetNowPlayingMovies(r)()).getOrElse((_) => []).first,
        const Movie(id: 1, title: 'Now 1', overview: 'Now overview 1'),
      );
      expect((await GetPopularMovies(r)()).getOrElse((_) => []).length, 3);
      expect(
        (await GetTopRatedMovies(r)()).getOrElse((_) => []).last.title,
        'Top 3',
      );
      expect(log.map((e) => e.path), [
        '/movie/now_playing',
        '/movie/popular',
        '/movie/top_rated',
      ]);
    });

    test('TV lists map results and call their endpoints', () async {
      final log = <RequestOptions>[];
      final r = repo(routes, log: log);
      expect(
        (await GetOnTheAirTv(r)()).getOrElse((_) => []).first,
        const Tv(
          id: 1,
          name: 'Air 1',
          overview: 'Air overview 1',
          voteAverage: 7.5,
        ),
      );
      expect((await GetPopularTv(r)()).getOrElse((_) => []).length, 3);
      expect(
        (await GetTopRatedTv(r)()).getOrElse((_) => []).last.name,
        'TvTop 3',
      );
      expect(log.map((e) => e.path), [
        '/tv/on_the_air',
        '/tv/popular',
        '/tv/top_rated',
      ]);
    });

    test('no network becomes ConnectionFailure', () async {
      expect(
        await repo({
          '/movie/now_playing': (0, <String, Object>{}),
        }).getNowPlayingMovies(),
        const Left<Failure, List<Movie>>(
          ConnectionFailure('Failed to connect to the network'),
        ),
      );
    });

    test('an error body without status_message uses the status code', () async {
      expect(
        await repo({'/tv/popular': (500, 'oops')}).getPopularTv(),
        const Left<Failure, List<Tv>>(ServerFailure('Server error (500)')),
      );
    });

    test('a missing title or name becomes an empty string', () {
      expect(
        MovieModel.fromJson(const {'id': 1}).toEntity(),
        const Movie(id: 1, title: ''),
      );
      expect(
        TvModel.fromJson(const {'id': 1, 'vote_average': 8}).toEntity(),
        const Tv(id: 1, name: '', voteAverage: 8),
      );
    });
  });

  group('HomeBloc', () {
    test('emits Loading then Loaded when all succeed', () async {
      final bloc = build(const Right([movie]));
      bloc.add(HomeFetched());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          HomeLoading(),
          const HomeLoaded(
            nowPlaying: [movie],
            popular: [movie],
            topRated: [movie],
          ),
        ]),
      );
    });

    test('emits Loading then Error when any section fails', () async {
      final bloc = build(const Left(ServerFailure('Invalid API key')));
      bloc.add(HomeFetched());
      await expectLater(
        bloc.stream,
        emitsInOrder([HomeLoading(), const HomeError('Invalid API key')]),
      );
    });
  });

  group('HomeTvBloc', () {
    test('loads On The Air, Popular and Top Rated series', () async {
      final bloc = buildTv(repo(routes));
      bloc.add(HomeTvFetched());
      await expectLater(
        bloc.stream,
        emitsInOrder([HomeTvLoading(), isA<HomeTvLoaded>()]),
      );
      final s = bloc.state as HomeTvLoaded;
      expect(s.onTheAir.first.name, 'Air 1');
      expect(s.popular.first.name, 'TvPop 1');
      expect(s.topRated.first.name, 'TvTop 1');
    });

    test('any failing list emits Error', () async {
      final bloc = buildTv(repo({'/tv/on_the_air': (200, tvList('Air'))}));
      bloc.add(HomeTvFetched());
      await expectLater(
        bloc.stream,
        emitsInOrder([HomeTvLoading(), const HomeTvError('not found')]),
      );
    });

    test('events compare by value', () {
      expect(HomeFetched(), HomeFetched());
      expect(HomeTvFetched(), HomeTvFetched());
    });
  });
}
