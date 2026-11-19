part of 'data.dart';

class SeeMoreItemModel {
  final int id;
  final MediaType type;
  final String title;
  final String? overview;
  final String? posterPath;

  const SeeMoreItemModel({
    required this.id,
    required this.type,
    required this.title,
    this.overview,
    this.posterPath,
  });

  factory SeeMoreItemModel.fromJson(
    MediaType type,
    Map<String, dynamic> json,
  ) => SeeMoreItemModel(
    id: json['id'],
    type: type,
    title: (type == MediaType.movie ? json['title'] : json['name']) ?? '',
    overview: json['overview'],
    posterPath: json['poster_path'],
  );

  SeeMoreItem toEntity() => SeeMoreItem(
    id: id,
    type: type,
    title: title,
    overview: overview,
    posterPath: posterPath,
  );
}
