part of 'data.dart';

class MovieModel {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  const MovieModel({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
  });

  factory MovieModel.fromJson(Map<String, dynamic> j) => MovieModel(
    id: j['id'],
    title: j['title'] ?? '',
    overview: j['overview'],
    posterPath: j['poster_path'],
  );

  Movie toEntity() =>
      Movie(id: id, title: title, overview: overview, posterPath: posterPath);

  static List<MovieModel> listFromJson(Map<String, dynamic> j) =>
      (j['results'] as List).map((e) => MovieModel.fromJson(e)).toList();
}
