part of '../favorites.dart';

sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();
  @override
  List<Object> get props => [];
}

final class WatchlistFetched extends WatchlistEvent {}
