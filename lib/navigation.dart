import 'package:about/about.dart';
import 'package:core/core.dart';
import 'package:detail_movie/detail_movie.dart';
import 'package:flutter/material.dart';
import 'package:search/search.dart';
import 'package:season/season.dart';
import 'package:see_more/see_more.dart';
import 'package:tv_detail/tv_detail.dart';
import 'package:watchlist/watchlist.dart';

Future<void> _push(BuildContext context, Widget page) =>
    Navigator.push<void>(context, MaterialPageRoute(builder: (_) => page));

Future<void> openMovie(BuildContext context, int id) =>
    _push(context, DetailMovieView(id: id, onRecommendationTap: openMovie));

Future<void> openTv(BuildContext context, int id) => _push(
  context,
  TvDetailView(id: id, onRecommendationTap: openTv, onSeasonTap: openSeason),
);

Future<void> openSeason(
  BuildContext context,
  int tvId,
  int seasonNumber,
  String title,
) => _push(
  context,
  SeasonPage(tvId: tvId, seasonNumber: seasonNumber, title: title),
);

Future<void> openMedia(BuildContext context, MediaType type, int id) =>
    switch (type) {
      MediaType.movie => openMovie(context, id),
      MediaType.tv => openTv(context, id),
    };

Future<void> openSeeMore(BuildContext context, MediaCategory category) => _push(
  context,
  SeeMorePage(title: category.title, category: category, onItemTap: openMedia),
);

Future<void> openSearch(BuildContext context) =>
    _push(context, const SearchPage(onItemTap: openTv));

Future<void> openWatchlist(BuildContext context) => _push(
  context,
  WatchlistPage(
    onItemTap: (context, item) => openMedia(context, item.type, item.id),
  ),
);

Future<void> openAbout(BuildContext context) =>
    _push(context, const AboutPage());
