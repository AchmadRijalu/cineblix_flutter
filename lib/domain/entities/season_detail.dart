part of 'entities.dart';

class SeasonDetail extends Equatable {
  final int seasonNumber;
  final String name;
  final String overview;
  final String? posterPath;
  final List<Episode> episodes;

  const SeasonDetail({
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.episodes,
  });

  @override
  List<Object?> get props => [
    seasonNumber,
    name,
    overview,
    posterPath,
    episodes,
  ];
}
