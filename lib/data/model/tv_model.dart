part of 'models.dart';

class TvModel {
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final double voteAverage;
  const TvModel({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.voteAverage = 0,
  });

  factory TvModel.fromJson(Map<String, dynamic> j) => TvModel(
    id: j['id'],
    name: j['name'] ?? '',
    overview: j['overview'],
    posterPath: j['poster_path'],
    voteAverage: (j['vote_average'] ?? 0).toDouble(),
  );

  Tv toEntity() => Tv(
    id: id,
    name: name,
    overview: overview,
    posterPath: posterPath,
    voteAverage: voteAverage,
  );

  MediaItem toMediaItem() => MediaItem(
    id: id,
    type: MediaType.tv,
    title: name,
    overview: overview,
    posterPath: posterPath,
    voteAverage: voteAverage,
  );

  static List<TvModel> listFromJson(Map<String, dynamic> j) =>
      (j['results'] as List).map((e) => TvModel.fromJson(e)).toList();
}
