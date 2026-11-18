part of '../domain.dart';

class MediaItem extends Equatable {
  final int id;
  final MediaType type;
  final String title;
  final String? overview;
  final String? posterPath;
  final double voteAverage;

  const MediaItem({
    required this.id,
    required this.type,
    required this.title,
    this.overview,
    this.posterPath,
    required this.voteAverage,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    overview,
    posterPath,
    voteAverage,
  ];
}
