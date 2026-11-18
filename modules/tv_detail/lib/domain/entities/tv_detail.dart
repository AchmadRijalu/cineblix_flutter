part of '../domain.dart';

class TvDetail extends Equatable {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final List<String> genres;
  final int numberOfSeasons;
  final String firstAirDate;
  final List<Season> seasons;
  const TvDetail({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.genres,
    required this.numberOfSeasons,
    required this.firstAirDate,
    this.seasons = const [],
  });
  @override
  List<Object?> get props => [
    id,
    name,
    overview,
    posterPath,
    voteAverage,
    genres,
    numberOfSeasons,
    firstAirDate,
    seasons,
  ];
}
