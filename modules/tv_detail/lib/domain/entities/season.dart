part of '../domain.dart';

class Season extends Equatable {
  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? posterPath;
  final String airDate;

  const Season({
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    required this.posterPath,
    required this.airDate,
  });

  @override
  List<Object?> get props => [
    seasonNumber,
    name,
    episodeCount,
    posterPath,
    airDate,
  ];
}
