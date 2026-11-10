part of '../detail_movie.dart';

sealed class DetailMovieState extends Equatable {
  const DetailMovieState();
  @override
  List<Object> get props => [];
}

final class DetailMovieInitial extends DetailMovieState {}

final class DetailMovieLoading extends DetailMovieState {}

final class DetailMovieLoaded extends DetailMovieState {
  final MovieDetail movie;
  final List<Movie> recommendations;
  final bool isAddedToWatchlist;
  final String watchlistMessage;
  final bool watchlistFailed;

  const DetailMovieLoaded(
    this.movie,
    this.recommendations,
    this.isAddedToWatchlist, {
    this.watchlistMessage = '',
    this.watchlistFailed = false,
  });

  @override
  List<Object> get props => [
    movie,
    recommendations,
    isAddedToWatchlist,
    watchlistMessage,
    watchlistFailed,
  ];
}

final class DetailMovieError extends DetailMovieState {
  final String message;
  const DetailMovieError(this.message);
  @override
  List<Object> get props => [message];
}
