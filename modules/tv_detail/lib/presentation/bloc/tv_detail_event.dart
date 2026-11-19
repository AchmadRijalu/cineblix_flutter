part of '../presentation.dart';

sealed class TvDetailEvent extends Equatable {
  const TvDetailEvent();
  @override
  List<Object> get props => [];
}

final class TvDetailFetched extends TvDetailEvent {
  final int id;
  const TvDetailFetched(this.id);
  @override
  List<Object> get props => [id];
}

final class TvDetailWatchlistToggled extends TvDetailEvent {}
