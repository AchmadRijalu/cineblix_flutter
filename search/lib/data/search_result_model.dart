part of 'data.dart';

class SearchResultModel {
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final double voteAverage;

  const SearchResultModel({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.voteAverage = 0,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) =>
      SearchResultModel(
        id: json['id'],
        name: json['name'] ?? '',
        overview: json['overview'],
        posterPath: json['poster_path'],
        voteAverage: (json['vote_average'] ?? 0).toDouble(),
      );

  SearchResult toEntity() => SearchResult(
    id: id,
    name: name,
    overview: overview,
    posterPath: posterPath,
    voteAverage: voteAverage,
  );

  static List<SearchResultModel> listFromJson(Map<String, dynamic> json) =>
      (json['results'] as List)
          .map((e) => SearchResultModel.fromJson(e))
          .toList();
}
