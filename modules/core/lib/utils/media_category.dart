part of 'commons.dart';

enum MediaCategory {
  nowPlaying(MediaType.movie, 'Now Playing'),
  popularMovies(MediaType.movie, 'Popular'),
  topRatedMovies(MediaType.movie, 'Top Rated'),
  onTheAir(MediaType.tv, 'On The Air'),
  popularTv(MediaType.tv, 'Popular'),
  topRatedTv(MediaType.tv, 'Top Rated');

  final MediaType type;
  final String title;
  const MediaCategory(this.type, this.title);
}
