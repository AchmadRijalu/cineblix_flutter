part of '../domain.dart';

class Tv extends Equatable {
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final double voteAverage;
  const Tv({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.voteAverage = 0,
  });
  @override
  List<Object?> get props => [id, name, overview, posterPath, voteAverage];
}
