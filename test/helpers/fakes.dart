import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:cineblix_flutter/domain/repositories/repositories.dart';
import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';

const dark = TvDetail(
  id: 1,
  name: 'Dark',
  overview: 'x',
  posterPath: '/p.jpg',
  voteAverage: 8.4,
  genres: ['Drama'],
  numberOfSeasons: 3,
  firstAirDate: '2017-12-01',
);
const darkTv = Tv(
  id: 1,
  name: 'Dark',
  overview: 'x',
  posterPath: '/p.jpg',
  voteAverage: 8.4,
);
const show1899 = Tv(id: 2, name: '1899');
const darkItem = MediaItem(
  id: 1,
  type: MediaType.tv,
  title: 'Dark',
  overview: 'x',
  posterPath: '/p.jpg',
  voteAverage: 8.4,
);
const inceptionItem = MediaItem(
  id: 1,
  type: MediaType.movie,
  title: 'Inception',
  voteAverage: 8.4,
);

class FakeTvDetailRepository implements TvDetailRepository {
  final Either<Failure, TvDetail> detail;
  final Either<Failure, List<Tv>> recommendations;
  FakeTvDetailRepository({
    this.detail = const Right(dark),
    this.recommendations = const Right([show1899]),
  });

  @override
  Future<Either<Failure, TvDetail>> getTvDetail(int id) async => detail;
  @override
  Future<Either<Failure, List<Tv>>> getTvRecommendations(int id) async =>
      recommendations;
}

class FakeWatchlistRepository implements WatchlistRepository {
  final Failure? failSave;
  final Failure? failGet;
  final Failure? failStatus;
  final items = <MediaItem>[];
  FakeWatchlistRepository({
    this.failSave,
    this.failGet,
    this.failStatus,
    List<MediaItem> initial = const [],
  }) {
    items.addAll(initial);
  }

  bool _same(MediaItem e, int id, MediaType type) =>
      e.id == id && e.type == type;

  @override
  Future<Either<Failure, String>> saveWatchlist(MediaItem item) async {
    if (failSave case final f?) return Left(f);
    items
      ..removeWhere((e) => _same(e, item.id, item.type))
      ..insert(0, item);
    return const Right('Added to Watchlist');
  }

  @override
  Future<Either<Failure, String>> removeWatchlist(
    int id,
    MediaType type,
  ) async {
    items.removeWhere((e) => _same(e, id, type));
    return const Right('Removed from Watchlist');
  }

  @override
  Future<Either<Failure, bool>> isAddedToWatchlist(
    int id,
    MediaType type,
  ) async {
    if (failStatus case final f?) return Left(f);
    return Right(items.any((e) => _same(e, id, type)));
  }

  @override
  Future<Either<Failure, List<MediaItem>>> getWatchlist() async {
    if (failGet case final f?) return Left(f);
    return Right(List.of(items));
  }
}
