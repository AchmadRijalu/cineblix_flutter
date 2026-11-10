import 'package:cineblix_flutter/common/commons.dart';
import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:cineblix_flutter/domain/repositories/repositories.dart';
import 'package:cineblix_flutter/domain/use_cases/use_cases.dart';
import 'package:cineblix_flutter/presentation/see_more/see_more.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakeSeeMoreRepository implements SeeMoreRepository {
  final bool failPage2;
  final requested = <(MediaCategory, int)>[];
  FakeSeeMoreRepository({this.failPage2 = false});

  @override
  Future<Either<Failure, MediaPage>> getItems(
    MediaCategory category,
    int page,
  ) async {
    requested.add((category, page));
    if (page == 2 && failPage2) return const Left(ServerFailure('boom'));
    return Right(
      MediaPage(
        items: [
          MediaItem(
            id: page,
            type: category.type,
            title: '$page',
            voteAverage: 0,
          ),
        ],
        page: page,
        totalPages: 2,
      ),
    );
  }
}

Future<SeeMoreState> settle(SeeMoreBloc bloc) =>
    bloc.stream.firstWhere((s) => s.status != RequestState.loading);

void main() {
  test('loads pages, appends, and stops at the last page', () async {
    final repo = FakeSeeMoreRepository();
    final bloc = SeeMoreBloc(
      GetSeeMoreItems(repo),
      MediaCategory.popularMovies,
    );

    bloc.add(SeeMoreFetched());
    expect((await settle(bloc)).items.map((m) => m.id), [1]);

    bloc.add(SeeMoreNextPageRequested());
    bloc.add(SeeMoreNextPageRequested());
    final s = await settle(bloc);
    expect(s.items.map((m) => m.id), [1, 2]);
    expect(s.hasMore, false);

    bloc.add(SeeMoreNextPageRequested());
    await Future<void>.delayed(Duration.zero);
    expect(repo.requested, [
      (MediaCategory.popularMovies, 1),
      (MediaCategory.popularMovies, 2),
    ]);
  });

  test('works the same for a TV category', () async {
    final repo = FakeSeeMoreRepository();
    final bloc = SeeMoreBloc(GetSeeMoreItems(repo), MediaCategory.onTheAir);
    bloc.add(SeeMoreFetched());
    expect((await settle(bloc)).items.single.type, MediaType.tv);
    expect(repo.requested, [(MediaCategory.onTheAir, 1)]);
  });

  test('next-page failure keeps loaded items', () async {
    final bloc = SeeMoreBloc(
      GetSeeMoreItems(FakeSeeMoreRepository(failPage2: true)),
      MediaCategory.popularMovies,
    );
    bloc.add(SeeMoreFetched());
    await settle(bloc);
    bloc.add(SeeMoreNextPageRequested());
    final s = await settle(bloc);
    expect(s.status, RequestState.failed);
    expect(s.items.map((m) => m.id), [1]);
  });

  test('categories know their media type and title', () {
    expect(
      [for (final c in MediaCategory.values) (c.type, c.title)],
      [
        (MediaType.movie, 'Now Playing'),
        (MediaType.movie, 'Popular'),
        (MediaType.movie, 'Top Rated'),
        (MediaType.tv, 'On The Air'),
        (MediaType.tv, 'Popular'),
        (MediaType.tv, 'Top Rated'),
      ],
    );
  });
}
