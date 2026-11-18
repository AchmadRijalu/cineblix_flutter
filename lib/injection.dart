import 'package:core/core.dart';
import 'package:detail_movie/detail_movie.dart';
import 'package:get_it/get_it.dart';
import 'package:home/home.dart';
import 'package:search/search.dart';
import 'package:season/season.dart';
import 'package:see_more/see_more.dart';
import 'package:tv_detail/tv_detail.dart';
import 'package:watchlist/watchlist.dart';

final locator = GetIt.instance;

void init() {
  initCore(locator);
  initHome(locator);
  initDetailMovie(locator);
  initSeeMore(locator);
  initTvDetail(locator);
  initSeason(locator);
  initSearch(locator);
  initWatchlist(locator);
}
