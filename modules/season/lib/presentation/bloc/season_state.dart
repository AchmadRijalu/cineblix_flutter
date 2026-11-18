part of '../presentation.dart';

sealed class SeasonState extends Equatable {
  const SeasonState();
  @override
  List<Object> get props => [];
}

final class SeasonInitial extends SeasonState {}

final class SeasonLoading extends SeasonState {}

final class SeasonLoaded extends SeasonState {
  final SeasonDetail season;
  const SeasonLoaded(this.season);
  @override
  List<Object> get props => [season];
}

final class SeasonError extends SeasonState {
  final String message;
  const SeasonError(this.message);
  @override
  List<Object> get props => [message];
}
