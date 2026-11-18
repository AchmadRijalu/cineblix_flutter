part of 'data.dart';

class WatchlistTable {
  final int id;
  final MediaType type;
  final String name;
  final String? overview;
  final String? posterPath;
  final double voteAverage;
  final int addedAt;

  const WatchlistTable({
    required this.id,
    required this.type,
    required this.name,
    this.overview,
    this.posterPath,
    required this.voteAverage,
    required this.addedAt,
  });

  factory WatchlistTable.fromEntity(MediaItem item) => WatchlistTable(
    id: item.id,
    type: item.type,
    name: item.title,
    overview: item.overview,
    posterPath: item.posterPath,
    voteAverage: item.voteAverage,
    addedAt: DateTime.now().millisecondsSinceEpoch,
  );

  factory WatchlistTable.fromMap(Map<String, Object?> m) => WatchlistTable(
    id: m['id'] as int,
    type: MediaType.values.byName(m['type'] as String),
    name: m['name'] as String,
    overview: m['overview'] as String?,
    posterPath: m['posterPath'] as String?,
    voteAverage: (m['voteAverage'] as num).toDouble(),
    addedAt: m['addedAt'] as int,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'type': type.name,
    'name': name,
    'overview': overview,
    'posterPath': posterPath,
    'voteAverage': voteAverage,
    'addedAt': addedAt,
  };

  MediaItem toEntity() => MediaItem(
    id: id,
    type: type,
    title: name,
    overview: overview,
    posterPath: posterPath,
    voteAverage: voteAverage,
  );
}
