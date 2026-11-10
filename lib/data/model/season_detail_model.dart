part of 'models.dart';

class SeasonDetailModel {
  final Map<String, dynamic> json;
  const SeasonDetailModel(this.json);

  SeasonDetail toEntity() => SeasonDetail(
    seasonNumber: json['season_number'],
    name: json['name'] ?? '',
    overview: json['overview'] ?? '',
    posterPath: json['poster_path'],
    episodes: [
      for (final e in json['episodes'] ?? [])
        Episode(
          episodeNumber: e['episode_number'],
          name: e['name'] ?? '',
          overview: e['overview'] ?? '',
          stillPath: e['still_path'],
          airDate: e['air_date'] ?? '',
          runtime: e['runtime'] ?? 0,
          voteAverage: (e['vote_average'] ?? 0).toDouble(),
        ),
    ],
  );
}
