import 'package:cineblix_flutter/domain/entities/entities.dart';
import 'package:cineblix_flutter/presentation/detail_movie/detail_movie.dart';
import 'package:cineblix_flutter/presentation/favorites/favorites.dart';
import 'package:cineblix_flutter/presentation/home/home.dart';
import 'package:cineblix_flutter/presentation/search/search.dart';
import 'package:cineblix_flutter/presentation/season/season.dart';
import 'package:cineblix_flutter/presentation/see_more/see_more.dart';
import 'package:cineblix_flutter/presentation/tv_detail/tv_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('events without fields are equal to each other', () {
    expect(HomeFetched(), HomeFetched());
    expect(DetailMovieWatchlistToggled(), DetailMovieWatchlistToggled());
    expect(TvDetailWatchlistToggled(), TvDetailWatchlistToggled());
    expect(WatchlistFetched(), WatchlistFetched());
    expect(SeeMoreFetched(), SeeMoreFetched());
    expect(SeeMoreNextPageRequested(), isNot(SeeMoreFetched()));
  });

  test('events with fields compare by value', () {
    expect(const TvDetailFetched(1), const TvDetailFetched(1));
    expect(const TvDetailFetched(1), isNot(const TvDetailFetched(2)));
    expect(const SearchQueryChanged('a'), const SearchQueryChanged('a'));
    expect(const SearchQueryChanged('a'), isNot(const SearchQueryChanged('b')));
    expect(const SeasonFetched(1, 2).props, [1, 2]);
  });

  test('MediaPage compares by value', () {
    const page = MediaPage(items: [], page: 1, totalPages: 2);
    expect(page, const MediaPage(items: [], page: 1, totalPages: 2));
    expect(page.hasMore, isTrue);
  });
}
