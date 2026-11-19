part of '../domain.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  const Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
  });
  @override
  List<Object?> get props => [id, title, overview, posterPath];
}
