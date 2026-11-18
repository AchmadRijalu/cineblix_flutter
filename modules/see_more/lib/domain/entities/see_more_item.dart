part of '../domain.dart';

class SeeMoreItem extends Equatable {
  final int id;
  final MediaType type;
  final String title;
  final String? overview;
  final String? posterPath;

  const SeeMoreItem({
    required this.id,
    required this.type,
    required this.title,
    this.overview,
    this.posterPath,
  });

  @override
  List<Object?> get props => [id, type, title, overview, posterPath];
}
