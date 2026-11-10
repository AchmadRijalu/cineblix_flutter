part of '../home.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<Movie> nowPlaying, popular, topRated;
  const HomeLoaded({
    required this.nowPlaying,
    required this.popular,
    required this.topRated,
  });
  @override
  List<Object> get props => [nowPlaying, popular, topRated];
}

final class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}
