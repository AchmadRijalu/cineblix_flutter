import 'package:cineblix_flutter/common/commons.dart';
import 'package:cineblix_flutter/data/data_sources/data_sources.dart';
import 'package:cineblix_flutter/data/repositories/repositories.dart';
import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:cineblix_flutter/domain/repositories/repositories.dart';
import 'package:cineblix_flutter/domain/use_cases/use_cases.dart';
import 'package:cineblix_flutter/presentation/home/home.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'helpers/fake_dio.dart';
import 'helpers/tmdb_fixtures.dart';

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
      final log = <RequestOptions>[];
      final bloc = buildTv(repo(allRoutes, log: log));
      bloc.add(HomeTvFetched());
      await expectLater(
        bloc.stream,
        emitsInOrder([HomeTvLoading(), isA<HomeTvLoaded>()]),
      );

      final s = bloc.state as HomeTvLoaded;
      expect(
        s.onTheAir.first,
        const Tv(
          id: 1,
          name: 'Air 1',
          overview: 'Air overview 1',
          voteAverage: 7.5,
        ),
      );
      expect(s.popular.first.name, 'TvPop 1');
      expect(s.topRated.first.name, 'TvTop 1');
      expect(log.map((r) => r.path).toSet(), {
        '/tv/on_the_air',
        '/tv/popular',
        '/tv/top_rated',
      });
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
      expect(HomeTvFetched(), HomeTvFetched());
    });
  });
}
