part of '../tv_detail.dart';

sealed class TvDetailState extends Equatable {
  const TvDetailState();
  @override
  List<Object> get props => [];
}

final class TvDetailInitial extends TvDetailState {}

final class TvDetailLoading extends TvDetailState {}

final class TvDetailLoaded extends TvDetailState {
  final TvDetail tv;
  final List<Tv> recommendations;
  final bool isAddedToWatchlist;

  final String watchlistMessage;
  final bool watchlistFailed;

  const TvDetailLoaded(
    this.tv,
    this.recommendations,
    this.isAddedToWatchlist, {
    this.watchlistMessage = '',
    this.watchlistFailed = false,
  });

  @override
  List<Object> get props => [
    tv,
    recommendations,
    isAddedToWatchlist,
    watchlistMessage,
    watchlistFailed,
  ];
}

final class TvDetailError extends TvDetailState {
  final String message;
  const TvDetailError(this.message);
  @override
  List<Object> get props => [message];
}
