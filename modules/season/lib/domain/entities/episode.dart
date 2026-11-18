part of '../domain.dart';

class Episode extends Equatable {
  final int episodeNumber;
  final String name;
  final String overview;
  final String? stillPath;
  final String airDate;
  final int runtime;
  final double voteAverage;

  const Episode({
    required this.episodeNumber,
    required this.name,
    required this.overview,
    required this.stillPath,
    required this.airDate,
    required this.runtime,
    required this.voteAverage,
  });

  @override
  List<Object?> get props => [
    episodeNumber,
    name,
    overview,
    stillPath,
    airDate,
    runtime,
    voteAverage,
  ];
}
