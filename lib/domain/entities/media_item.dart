part of 'entities.dart';

enum MediaType { movie, tv }

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

  factory MediaItem.fromTv(TvDetail tv) => MediaItem(
    id: tv.id,
    type: MediaType.tv,
    title: tv.name,
    overview: tv.overview,
    posterPath: tv.posterPath,
    voteAverage: tv.voteAverage,
  );

  factory MediaItem.fromMovie(MovieDetail m) => MediaItem(
    id: m.id,
    type: MediaType.movie,
    title: m.title,
    overview: m.overview,
    posterPath: m.posterPath,
    voteAverage: m.voteAverage,
  );

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
