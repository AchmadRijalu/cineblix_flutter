import 'package:cineblix_flutter/data/model/models.dart';
import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'TvModel parses a result with null poster/overview and no vote_average',
    () {
      expect(
        TvModel.fromJson({
          'id': 1,
          'name': 'Dark',
          'overview': null,
          'poster_path': null,
        }).toEntity(),
        const Tv(id: 1, name: 'Dark'),
      );
    },
  );

  test('TvDetailModel maps genres, seasons and int vote_average', () {
    final d = const TvDetailModel({
      'id': 1,
      'name': 'Dark',
      'overview': 'x',
      'poster_path': '/p.jpg',
      'vote_average': 8,
      'genres': [
        {'id': 18, 'name': 'Drama'},
      ],
      'number_of_seasons': 3,
      'first_air_date': '2017-12-01',
    }).toEntity();
    expect(d.voteAverage, 8.0);
    expect(d.genres, ['Drama']);
    expect(d.numberOfSeasons, 3);
  });

  test('TvDetailModel tolerates missing optional fields', () {
    expect(
      const TvDetailModel({'id': 1, 'name': 'Dark'}).toEntity(),
      const TvDetail(
        id: 1,
        name: 'Dark',
        overview: '',
        posterPath: null,
        voteAverage: 0,
        genres: [],
        numberOfSeasons: 0,
        firstAirDate: '',
      ),
    );
  });

  test('TvModel.listFromJson reads results', () {
    expect(
      TvModel.listFromJson({
        'results': [
          {'id': 2, 'name': '1899'},
        ],
      }).single.toEntity().id,
      2,
    );
  });
}
