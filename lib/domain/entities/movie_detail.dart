part of 'entities.dart';

class MovieDetail extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String releaseDate;
  final int runtime;
  final double voteAverage;
  final List<String> genres;
  const MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.runtime,
    required this.voteAverage,
    required this.genres,
  });
  @override
  List<Object?> get props => [
    id,
    title,
    overview,
    posterPath,
    releaseDate,
    runtime,
    voteAverage,
    genres,
  ];
}
