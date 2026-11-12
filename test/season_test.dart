import 'package:cineblix_flutter/data/data_sources/data_sources.dart';
import 'package:cineblix_flutter/data/model/models.dart';
import 'package:cineblix_flutter/data/repositories/repositories.dart';
import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:cineblix_flutter/domain/use_cases/use_cases.dart';
import 'package:cineblix_flutter/presentation/season/season.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'helpers/fake_dio.dart';
import 'helpers/tmdb_fixtures.dart';

const secrets = Episode(
  episodeNumber: 1,
  name: 'Secrets',
  overview: 'Mikkel disappears.',
  stillPath: null,
  airDate: '2017-12-01',
  runtime: 51,
  voteAverage: 8.1,
);

const lies = Episode(
  episodeNumber: 2,
  name: 'Lies',
  overview: '',
  stillPath: null,
  airDate: '',
  runtime: 0,
  voteAverage: 0,
);

const season1 = SeasonDetail(
  seasonNumber: 1,
  name: 'Season 1',
  overview: 'A child goes missing.',
  posterPath: null,
  episodes: [secrets, lies],
);

GetSeasonDetail useCase(
  Map<String, (int, Object)> routes, {
  List<RequestOptions>? log,
}) => GetSeasonDetail(
  SeasonRepositoryImpl(SeasonRemoteDataSource(fakeDio(routes, log: log))),
);

void main() {
  group('models', () {
    test('TvDetailModel maps seasons', () {
      expect(const TvDetailModel(tvDetailJson).toEntity().seasons, const [
        Season(
          seasonNumber: 1,
          name: 'Season 1',
          episodeCount: 10,
          posterPath: null,
          airDate: '2017-12-01',
        ),
        Season(
          seasonNumber: 2,
          name: 'Season 2',
          episodeCount: 8,
          posterPath: null,
          airDate: '2019-06-21',
        ),
      ]);
    });

    test('TvDetailModel without seasons gives an empty list', () {
      expect(
        const TvDetailModel({'id': 1, 'name': 'Dark'}).toEntity().seasons,
        isEmpty,
      );
    });

    test('SeasonDetailModel maps episodes and tolerates missing fields', () {
      expect(const SeasonDetailModel(seasonJson).toEntity(), season1);
      expect(
        const SeasonDetailModel({'season_number': 3}).toEntity(),
        const SeasonDetail(
          seasonNumber: 3,
          name: '',
          overview: '',
          posterPath: null,
          episodes: [],
        ),
      );
    });
  });

  group('repository', () {
    test('calls /tv/{id}/season/{number} and maps to entity', () async {
      final log = <RequestOptions>[];
      expect(
        await useCase(allRoutes, log: log)(1, 1),
        const Right<Failure, SeasonDetail>(season1),
      );
      expect(log.single.path, '/tv/1/season/1');
    });

    test('HTTP error becomes ServerFailure', () async {
      expect(
        await useCase({})(1, 9),
        const Left<Failure, SeasonDetail>(ServerFailure('not found')),
      );
    });
  });

  group('bloc', () {
    test('emits Loading then Loaded', () async {
      final bloc = SeasonBloc(useCase(allRoutes));
      bloc.add(const SeasonFetched(1, 1));
      await expectLater(
        bloc.stream,
        emitsInOrder([SeasonLoading(), const SeasonLoaded(season1)]),
      );
    });

    test('emits Loading then Error on failure', () async {
      final bloc = SeasonBloc(useCase({}));
      bloc.add(const SeasonFetched(1, 1));
      await expectLater(
        bloc.stream,
        emitsInOrder([SeasonLoading(), const SeasonError('not found')]),
      );
    });

    test('events compare by tv id and season number', () {
      expect(const SeasonFetched(1, 1), const SeasonFetched(1, 1));
      expect(const SeasonFetched(1, 1), isNot(const SeasonFetched(1, 2)));
    });
  });
}
