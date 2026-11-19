import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';

import 'domain/domain.dart';

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
