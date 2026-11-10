part of '../season.dart';

sealed class SeasonEvent extends Equatable {
  const SeasonEvent();
  @override
  List<Object> get props => [];
}

final class SeasonFetched extends SeasonEvent {
  final int tvId;
  final int seasonNumber;
  const SeasonFetched(this.tvId, this.seasonNumber);
  @override
  List<Object> get props => [tvId, seasonNumber];
}
