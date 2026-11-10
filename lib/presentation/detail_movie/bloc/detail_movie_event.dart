part of '../detail_movie.dart';

sealed class DetailMovieEvent extends Equatable {
  const DetailMovieEvent();
  @override
  List<Object> get props => [];
}

final class DetailMovieFetched extends DetailMovieEvent {
  final int id;
  const DetailMovieFetched(this.id);
  @override
  List<Object> get props => [id];
}

final class DetailMovieWatchlistToggled extends DetailMovieEvent {}
