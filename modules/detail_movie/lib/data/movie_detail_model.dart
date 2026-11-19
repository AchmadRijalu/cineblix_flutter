part of 'data.dart';

class MovieDetailModel {
  final Map<String, dynamic> json;
  const MovieDetailModel(this.json);

  MovieDetail toEntity() => MovieDetail(
    id: json['id'],
    title: json['title'] ?? '',
    overview: json['overview'] ?? '',
    posterPath: json['poster_path'],
    releaseDate: json['release_date'] ?? '',
    runtime: json['runtime'] ?? 0,
    voteAverage: (json['vote_average'] ?? 0).toDouble(),
    genres: [for (final g in json['genres'] ?? []) g['name'] as String],
  );
}
