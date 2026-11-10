part of 'models.dart';

class TvDetailModel {
  final Map<String, dynamic> json;
  const TvDetailModel(this.json);

  TvDetail toEntity() => TvDetail(
    id: json['id'],
    name: json['name'] ?? '',
    overview: json['overview'] ?? '',
    posterPath: json['poster_path'],
    voteAverage: (json['vote_average'] ?? 0).toDouble(),
    genres: [for (final g in json['genres'] ?? []) g['name'] as String],
    numberOfSeasons: json['number_of_seasons'] ?? 0,
    firstAirDate: json['first_air_date'] ?? '',
    seasons: [
      for (final s in json['seasons'] ?? [])
        Season(
          seasonNumber: s['season_number'],
          name: s['name'] ?? '',
          episodeCount: s['episode_count'] ?? 0,
          posterPath: s['poster_path'],
          airDate: s['air_date'] ?? '',
        ),
    ],
  );
}
